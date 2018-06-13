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

local function TimerIsFinished(timer)
    return GetTime() >= (timer.expiration or 0)
end

function Timers:Insert(unitGUID, srcGUID, category, spellID, isFriendly, isApplied, testMode, destName)
    if isApplied then -- SPELL_AURA_APPLIED
        if NS.db.displayMode == "ON_AURA_END" and not testMode then
            -- ON_AURA_END mode we start timer on SPELL_AURA_REMOVED instead of APPLIED
            return
        end
    else -- SPELL_AURA_REMOVED
        if NS.db.displayMode == "ON_AURA_START" then
            return self:Update(unitGUID, category, spellID, isFriendly, nil, isApplied)
        end
    end

    local timers = activeTimers[unitGUID]
    if timers and timers[category] then
        -- Timer already active
        return self:Update(unitGUID, category, spellID, isFriendly, true)
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

    activeTimers[unitGUID][category] = timer
    StartTimers(timer, isApplied)
end

function Timers:Update(unitGUID, category, spellID, isFriendly, updateApplied, isApplied, destName)
    local timer = activeTimers[unitGUID] and activeTimers[unitGUID][category]
    if not timer then
        if isApplied then
            -- TODO: verify if this works
            -- SPELL_AURA_REFRESH or APPLIED didn't detect DR (if out of range etc)
            -- but SPELL_AURA_REMOVED was detected later, so create new timer here
            NS.Info("Update not timer ran")
            Timers:Insert(unitGUID, category, spellID, isFriendly, destName)
        end
        return
    end

    if updateApplied then
        timer.applied = (timer.applied or 0) + 1
    end

    timer.spellID = spellID
    timer.isFriendly = isFriendly
    timer.expiration = GetTime() + (not timer.testMode and DR_TIME or random(6, DR_TIME))

    StartTimers(timer, true, nil, true)
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
        for cat, t in pairs(timers) do
            if t.unitClass == "HUNTER" or NS.Diminish:UnitIsHunter(t.destName) then
                -- UNIT_DIED is fired for Feign Death so ignore hunters here
                NS.Info("hunter UNIT_DIED remove")
                return
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

    local _, englishClass = UnitClass(unitID)

    -- Start (or delete) timers belonging to current guid
    if activeTimers[unitGUID] then
        for category, timer in pairs(activeTimers[unitGUID]) do
            if not timer.unitClass then
                -- Used to detect hunters, we need to ignore Feign Death for UNIT_DIED later on
                timer.unitClass = englishClass
            end

            if not TimerIsFinished(timer) then
                StartTimers(timer, true, unitID, nil, true)
            else
                StopTimers(timer, unitID)
            end
        end
    end
end

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
        wipe(activeGUIDs)
    end
    activeGUIDs.player = UnitGUID("player")

    Debug("Stopped all timers.")
end

do
    local GetAuraDuration = NS.GetAuraDuration

    local testModeUnits = {
        "player", "player-party", "target", "focus",
        "arena1", "arena2", "arena3",
        "party1", "party2", "party3",
    }

    local function Start(timer, isApplied, unitID, isUpdate, isRefresh)
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
        if isApplied and NS.db.displayMode == "ON_AURA_START" then
            if not timer.testMode and not isRefresh then -- TODO: test
                local duration = GetAuraDuration(origUnitID or unitID, timer.spellID)
                if duration and duration > 0 then
                    timer.expiration = GetTime() + DR_TIME + (duration or 0)
                end
            end
        end

        Icons:StartCooldown(timer, origUnitID and "player-party" or unitID)
        Debug("%s timer %s:%s", isUpdate and "Updated" or "Started", origUnitID and "player-party" or unitID, timer.category)
    end

    local function Stop(timer, unitID, preventRemove)
        Icons:StopCooldown(timer, unitID, TimerIsFinished(timer))
        Debug("Stop/pause timer %s:%s", unitID, timer.category or "nil")

        if not preventRemove then
            -- f.cooldown OnHide script won't trigger :Remove() if the parent (unitframe) is hidden
            -- so attempt to remove timer here aswell if it isn't already being removed or we're just refreshing
            Timers:Remove(timer.unitGUID, timer.category, true)
        end
    end

    function StartTimers(timer, isApplied, unit, isUpdate, isRefresh)
        if timer.testMode then
            -- When testing, we want to show timers for all enabled frames
            for i = 1, #testModeUnits do
                Start(timer, isApplied, testModeUnits[i], isUpdate, isRefresh)
            end
            return
        end

        if unit then
            -- Start/update timer only for this unitID
            return Start(timer, isApplied, unit, isUpdate, isRefresh)
        end

        -- Start timer for every unitID that matches timer unit guid
        -- This is so we can show the *same* timer for e.g both FocusFrame and TargetFrame at the same time
        -- without having to create duplicate tables
        local unitGUID = timer.unitGUID
        for unit, guid in pairs(activeGUIDs) do
            if guid == unitGUID then
                Start(timer, isApplied, unit, isUpdate, isRefresh)

                if unit == "player" then
                    if NS.useCompactPartyFrames and NS.db.unitFrames.party.isEnabledForZone then
                        Start(timer, isApplied, "player-party", isUpdate, isRefresh)
                    end
                end
            end
        end
    end

    function StopTimers(timer, unit, preventRemove)
        if timer.testMode then
            for i = 1, #testModeUnits do
                Stop(timer, testModeUnits[i], preventRemove)
            end
            return
        end

        if unit then
            return Stop(timer, unit, preventRemove)
        end

        local unitGUID = timer.unitGUID
        for unit, guid in pairs(activeGUIDs) do
            if guid == unitGUID then
                Stop(timer, unit, preventRemove)

                if unit == "player" then
                    Stop(timer, "player-party", true)
                end
            end
        end
    end
end
