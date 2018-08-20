local _, NS = ...
local Timers = {}
NS.Timers = Timers

local StopTimers, StartTimers
local activeTimers = {}
local activeGUIDs = {}

local DR_TIME = NS.DR_TIME
local Icons = NS.Icons
local Debug = NS.Debug
local NewTable = NS.NewTable
local RemoveTable = NS.RemoveTable

local UnitGUID = _G.UnitGUID
local UnitClass = _G.UnitClass
local GetTime = _G.GetTime
local gsub = _G.string.gsub
local pairs = _G.pairs
local next = _G.next

local function TimerIsFinished(timer, timestamp)
    return (timestamp or GetTime()) >= (timer.expiration or 0)
end

function Timers:Insert(unitGUID, srcGUID, category, spellID, isFriendly, isApplied, testMode, destName, ranFromUpdate)
    if isApplied then -- SPELL_AURA_APPLIED
        if NS.db.timerStartAuraEnd and not testMode then
            -- on timerStartAuraEnd=true mode we start timer on SPELL_AURA_REMOVED instead of APPLIED
            -- but update timer immediately if it already exists & there's less than 5 sec left or else it's possible that a CC aura is applied
            -- while timer is being removed or right before, and when the aura ends it will show incorrect timer
            if activeTimers[unitGUID] and activeTimers[unitGUID][category] then
                local timer = activeTimers[unitGUID][category]
                local duration = timer.expiration - GetTime()
                if duration <= 5 and duration > 0.5 then
                    self:Update(unitGUID, srcGUID, category, spellID, isFriendly, nil, isApplied)
                end
            end

            return
        end
    else -- SPELL_AURA_REMOVED
        if not NS.db.timerStartAuraEnd then
            if activeTimers[unitGUID] and activeTimers[unitGUID][category] then
                -- Update timer expiration without updating indicator color for this mode
                return self:Update(unitGUID, srcGUID, category, spellID, isFriendly, nil, isApplied, nil, true)
            end
        end
    end

    local timers = activeTimers[unitGUID]
    if timers and timers[category] then
        -- Timer already active, update everything
        return self:Update(unitGUID, srcGUID, category, spellID, isFriendly, true)
    end

    if not timers then
        activeTimers[unitGUID] = {}
    end

    local timer = NewTable() -- table pooling from helpers.lua
    timer.expiration = GetTime() + (not testMode and DR_TIME or random(6, DR_TIME))
    timer.applied = not testMode and 1 or random(1, 3)
    timer.category = category
    timer.isFriendly = isFriendly
    timer.spellID = spellID
    timer.unitGUID = unitGUID
    timer.srcGUID = srcGUID
    timer.destName = destName
    timer.testMode = testMode

    if ranFromUpdate and not NS.db.timerStartAuraEnd then
        -- SPELL_AURA/APPLIED/BROKEN didn't detect DR, but REFRESH did
        -- and also since the aura was refreshed it means we're atleast 2 on applied
        timer.applied = 2
    end

    activeTimers[unitGUID][category] = timer
    StartTimers(timer, isApplied, nil, nil, nil, not isApplied)
end

function Timers:Update(unitGUID, srcGUID, category, spellID, isFriendly, updateApplied, isApplied, destName, onAuraEnd)
    local timer = activeTimers[unitGUID] and activeTimers[unitGUID][category]
    if not timer then
        if isApplied or updateApplied then
            -- SPELL_AURA_APPLIED/BROKEN didn't detect DR, but REFRESH did
            Timers:Insert(unitGUID, srcGUID, category, spellID, isFriendly, false, nil, destName, true)
        end
        return
    end

    if updateApplied then
        timer.applied = (timer.applied or 0) + 1
    end

    timer.spellID = spellID
    timer.isFriendly = isFriendly
    timer.expiration = GetTime() + (not timer.testMode and DR_TIME - 0.1 or random(6, DR_TIME))

    StartTimers(timer, true, nil, true, nil, onAuraEnd)
end

function Timers:Remove(unitGUID, category, noStop)
    local timers = activeTimers[unitGUID]
    if not timers then return end

    if category then
        local timer = timers[category]
        if not timer then return end

        if not noStop then
            StopTimers(timer, nil, true)
        end

        if timers then
            RemoveTable(timers[category])
            timers[category] = nil -- remove ref to table in pool but not table itself
        end
    elseif category == false then
        -- Stop all active timers for guid (UNIT_DIED, PARTY_KILL)
        -- Only ran outside arena.
        local Diminish = NS.Diminish
        local hunterCheckRan = false

        for cat, t in pairs(timers) do
            if not hunterCheckRan then
                -- UNIT_DIED is fired for Feign Death so ignore hunters here
                if t.unitClass == "HUNTER" then return end
                if Diminish:UnitIsHunter(t.destName) then return end
                if Diminish.currInstanceType ~= "pvp" and not t.unitClass then return end
                hunterCheckRan = true -- don't run next loop iterations
            end

            if not noStop then
                StopTimers(t, nil, true)
            end

            RemoveTable(t)
            timers[cat] = nil
        end
    end

    if not next(timers) then
        RemoveTable(timers)
        activeTimers[unitGUID] = nil
    end
end

function Timers:Refresh(unitID)
    local unitGUID = UnitGUID(unitID)
    local prevGUID = activeGUIDs[unitID]
    activeGUIDs[unitID] = unitGUID
    if not unitGUID then return end

    -- Hide active timers belonging to previous guid
    -- Note, its probably faster to always just :Hide() frames but this
    -- will also delete any old timers
    if prevGUID and prevGUID ~= unitGUID and activeTimers[prevGUID] then
        for category, timer in pairs(activeTimers[prevGUID]) do
            StopTimers(timer, unitID, true)
        end
    else
        -- No prev guid available, hide ALL frames for this unitID instead
        if NS.iconFrames[unitID] then
            for category, frame in pairs(NS.iconFrames[unitID]) do
                if frame.shown then
                    frame.shown = false
                    frame:Hide()
                end
            end
        end
    end

    -- Start or delete timers belonging to current guid
    if activeTimers[unitGUID] then
        local _, englishClass = UnitClass(unitID)
        local currTime = GetTime()

        for category, timer in pairs(activeTimers[unitGUID]) do
            if not timer.unitClass then
                -- Used to detect hunters, we need to ignore Feign Death for UNIT_DIED later on
                timer.unitClass = englishClass
            end

            if not TimerIsFinished(timer, currTime) then
                StartTimers(timer, true, unitID, nil, true)
            else
                StopTimers(timer, unitID)
            end
        end
    end
end

C_Timer.NewTicker(55, function()
    -- Remove inactive timers every X seconds incase they
    -- weren't detected in Refresh(), UNIT_DIED or OnHide script for removal

    if NS.Diminish.currInstanceType ~= "arena" then
        local currTime = GetTime()
        for guid, categories in pairs(activeTimers) do
            for cat, timer in pairs(categories) do
                if TimerIsFinished(timer, currTime) then
                    StopTimers(timer)
                end
            end
        end
    end
end)

function Timers:ResetAll(clearGUIDs)
    for guid, categories in pairs(activeTimers) do
        for cat, t in pairs(categories) do
            RemoveTable(t)
            categories[cat] = nil
        end

        RemoveTable(activeTimers[guid])
        activeTimers[guid] = nil
    end

    NS.ReleaseTables()
    Icons:HideAll()

    if clearGUIDs then
        for unitID, guid in pairs(activeGUIDs) do
            if not UnitExists(unitID) then
                activeGUIDs[unitID] = nil
            end
        end
    end

    if not activeGUIDs.player then
        -- cache on first Diminish:Enable()
        activeGUIDs.player = UnitGUID("player")
    end

    --@debug@
    Debug("Stopped all timers.")
    --@end-debug@
end

do
    local GetAuraDuration = NS.GetAuraDuration
    local CATEGORY_TAUNT = NS.CATEGORIES.TAUNT

    local testModeUnits = {
        "player", "player-party", "target", "focus",
        "arena1", "arena2", "arena3",
        "party1", "party2", "party3",
    }

    local function Start(timer, isApplied, unitID, isUpdate, isRefresh, onAuraEnd)
        local origUnitID
        if unitID == "player-party" then -- CompactRaidFrame for player (no partyX id available for player)
            unitID = "party"  -- just so we can use party settings below
            origUnitID = "player" -- real unit ID used for blizzard functions, player-party will be used for Diminish functions
        end

        -- Check if disabled
        local settings = NS.db.unitFrames[gsub(unitID, "%d", "")]
        if not settings or not settings.enabled then return end
        if not timer.testMode and not settings.isEnabledForZone then return end
        if not settings.watchFriendly and timer.isFriendly then return end
        if settings.disabledCategories[timer.category] then return end

        -- Add aura duration to DR timer(18s) if using display mode on aura start
        if isApplied and not NS.db.timerStartAuraEnd then
            if not timer.testMode --[[and not isRefresh]] then
                -- TODO: only run on APPLIED/REFRESH/BROKEN ?
                local duration, expirationTime = GetAuraDuration(origUnitID or unitID, timer.spellID)

                if expirationTime and expirationTime > 0 then
                    timer.expiration = (expirationTime or GetTime()) + DR_TIME

                    if timer.applied >= 2 and duration >= 5 then
                        -- is no DR but timer shows immune/75%
                        -- may happen if server reset DR before our timer did & new CC got applied
                        timer.applied = 1
                    elseif timer.applied > 3 and duration > 0 then
                        -- Timer shows immune but aura duration was found, so reset
                        if timer.category ~= CATEGORY_TAUNT then
                            timer.applied = 1
                        end
                    end
                end
            end
        end

        Icons:StartCooldown(timer, origUnitID and "player-party" or unitID, onAuraEnd)
        --@debug@
        Debug("%s timer %s:%s", isUpdate and "Updated" or "Started", origUnitID and "player-party" or unitID, timer.category)
        --@end-debug@
    end

    local function Stop(timer, unitID, preventRemove, isFinished)
        Icons:StopCooldown(timer, unitID, isFinished)
        --@debug@
        Debug("Stop/pause timer %s:%s", unitID, timer.category or "nil")
        --@end-debug@

        if not preventRemove then
            -- f.cooldown OnHide script won't trigger :Remove() if the parent (unitframe) is hidden
            -- so attempt to remove timer here aswell if it isn't already being removed or we're just refreshing
            Timers:Remove(timer.unitGUID, timer.category, true)
        end
    end

    function StartTimers(timer, isApplied, unit, isUpdate, isRefresh, onAuraEnd)
        if timer.testMode then
            -- When testing, we want to show timers for all enabled frames
            for i = 1, #testModeUnits do
                Start(timer, isApplied, testModeUnits[i], isUpdate, isRefresh, onAuraEnd)
            end
            return
        end

        if unit then
            -- Start/update timer only for this unitID
            return Start(timer, isApplied, unit, isUpdate, isRefresh, onAuraEnd)
        end

        -- Start timer for EVERY unitID that matches timer unit guid.
        local unitGUID = timer.unitGUID
        for unit, guid in pairs(activeGUIDs) do
            if guid == unitGUID then
                Start(timer, isApplied, unit, isUpdate, isRefresh, onAuraEnd)

                if unit == "player" then
                    if NS.useCompactPartyFrames and NS.db.unitFrames.party.isEnabledForZone then
                        Start(timer, isApplied, "player-party", isUpdate, isRefresh, onAuraEnd)
                    end
                end
            end
        end
    end

    function StopTimers(timer, unit, preventRemove)
        local isFinished = TimerIsFinished(timer) -- cache result for loops

        if timer.testMode then
            for i = 1, #testModeUnits do
                Stop(timer, testModeUnits[i], preventRemove, isFinished)
            end
            return
        end

        if unit then
            return Stop(timer, unit, preventRemove, isFinished)
        end

        local unitGUID = timer.unitGUID
        for unit, guid in pairs(activeGUIDs) do
            if guid == unitGUID then
                Stop(timer, unit, preventRemove, isFinished)

                if unit == "player" then
                    Stop(timer, "player-party", true, isFinished)
                end
            end
        end
    end
end
