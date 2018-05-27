local _, NS = ...
local Timers = NS.Timers
local Debug = NS.Debug
local Info = NS.Info

local Diminish = CreateFrame("Frame")
Diminish:RegisterEvent("PLAYER_LOGIN")
Diminish:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
end)

-- used for Diminish_Options
NS.Diminish = Diminish
DIMINISH_NS = NS

local unitEvents = {
    target = "PLAYER_TARGET_CHANGED",
    focus = "PLAYER_FOCUS_CHANGED",
    party = "GROUP_ROSTER_UPDATE",
    arena = "ARENA_OPPONENT_UPDATE",
}

function Diminish:ToggleForZone()
    local _, instanceType = IsInInstance()
    local registeredOnce = false

    -- (Un)register unit events for current zone depending on user settings
    for unit, settings in pairs(NS.db.unitFrames) do -- DR tracking for focus/target etc each have their own seperate settings
        if settings.enabled then
            local event = unitEvents[unit]

            -- Loop through every zone/instance enabled and see if we're currently in that instance
            for zone, state in pairs(settings.zones) do
                if unit ~= "player" then
                    if state and zone == instanceType then
                        registeredOnce = true
                        settings.isEnabledForZone = true -- cache for later

                        if not self:IsEventRegistered(event) then
                            self:RegisterEvent(event)
                            Debug("Registered %s for instance %s.", event, instanceType)
                        end

                        break
                    else
                        settings.isEnabledForZone = false
                        if self:IsEventRegistered(event) then
                            self:UnregisterEvent(event)
                            Debug("Unregistered %s for instance %s.", event, instanceType)
                        end
                    end
                else
                    -- Make sure CLEU etc is still registered when only "player" is being tracked for a zone
                    -- (There's no unit event that need registration for Player)
                    registeredOnce = registeredOnce or zone == instanceType
                    settings.isEnabledForZone = registeredOnce
                end
            end
        else
            settings.isEnabledForZone = false
        end
    end

    if registeredOnce then
        self:SetCLEUWatchVariables()
        self:Enable()
    else
        self:Disable()
    end
end

function Diminish:SetCLEUWatchVariables()
    local cfg = NS.db.unitFrames

    local targetOrFocusWatchFriendly = false
    if cfg.target.watchFriendly and cfg.target.isEnabledForZone then
        targetOrFocusWatchFriendly = true
    elseif cfg.focus.watchFriendly and cfg.focus.isEnabledForZone then
        targetOrFocusWatchFriendly = true
    end

    -- Check if we're tracking any friendly units and not just enemy only
    self.isWatchingFriendly = false
    if cfg.player.isEnabledForZone or cfg.party.isEnabledForZone or targetOrFocusWatchFriendly then
        self.isWatchingFriendly = true
    end

    -- Check if only PlayerFrame tracking is enabled for friendly, if it is
    -- we want to ignore all friendly units later in CLEU except where destGUID == playerGUID
    self.onlyPlayerWatchFriendly = cfg.player.isEnabledForZone
    if cfg.player.isEnabledForZone then
        if cfg.party.isEnabledForZone or targetOrFocusWatchFriendly then
            self.onlyPlayerWatchFriendly = false
        end
    end

    -- Check if we're only tracking friendly units so we can ignore enemy units in CLEU
    self.onlyFriendlyTracking = true
    if cfg.target.isEnabledForZone or cfg.focus.isEnabledForZone or cfg.arena.isEnabledForZone then
        self.onlyFriendlyTracking = false
    end

    -- Check if we're only tracking friendly party members so we can ignore outsiders
    self.onlyTrackingPartyForFriendly = cfg.party.isEnabledForZone
    if targetOrFocusWatchFriendly then
        self.onlyTrackingPartyForFriendly = false
    end
end

function Diminish:Disable()
    Timers:ResetAll(true)
    self:UnregisterAllEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CVAR_UPDATE")
    Info("Disabled for zone %s.", select(2, IsInInstance()))
end

function Diminish:Enable()
    self.currInstanceType = select(2, IsInInstance())
    Info("Enabled for zone %s.", self.currInstanceType)
    Timers:ResetAll(true)

    if self.currInstanceType == "arena" or self.currInstanceType == "pvp" then
        -- Always keep CLEU registered when in arena/bg's for more accurate tracking
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    else
        -- Outdoors, only register CLEU while in combat.
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
    end
end

function Diminish:InitDB()
    DiminishDB = DiminishDB and next(DiminishDB) ~= nil and DiminishDB or {
        version = GetAddOnMetadata("Diminish", "Version"),
        profileKeys = {},
        profiles = {},
    }

    -- Reset config completly if updating from 2.0.0b-0.1
    -- TODO: remove this when beta is over
    if not DiminishDB.version then
        wipe(DiminishDB)
        self:InitDB()
        return
    end
    DiminishDB.version = GetAddOnMetadata("Diminish", "Version")

    local playerName = UnitName("player") .. "-" .. GetRealmName()
    local profile = DiminishDB.profileKeys[playerName]

    if not profile or not DiminishDB.profiles[profile] then
        -- Profile doesn't exist or is deleted, reset to default
        DiminishDB.profileKeys[playerName] = "Default"
        profile = "Default"
    end

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults({
        [profile] = NS.DEFAULT_SETTINGS
    }, DiminishDB.profiles)

    NS.db = DiminishDB.profiles[profile]
    NS.activeProfile = profile
    -- Note: Diminish_Options will be handling modification of profiles from now on

    NS.DEFAULT_SETTINGS = nil
    self.InitDB = nil
end

--------------------------------------------------------------
-- Events
--------------------------------------------------------------

function Diminish:PLAYER_LOGIN()
    self:InitDB()
    self.PLAYER_GUID = UnitGUID("player")

    -- Call these on login aswell and not just GROUP_ROSTER_UPDATE incase the
    -- player joins a group while in combat where we cant anchor/create the frames
    NS.useCompactPartyFrames = GetCVarBool("useCompactPartyFrames")
    NS.Icons:AnchorRaidFrames()
    NS.Icons:AnchorPartyFrames()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CVAR_UPDATE")
    self:UnregisterEvent("PLAYER_LOGIN")
    self.PLAYER_LOGIN = nil
end

function Diminish:CVAR_UPDATE(name, value)
    if name ~= "USE_RAID_STYLE_PARTY_FRAMES" then return end

    if value == "0" then
        NS.useCompactPartyFrames = false
        NS.Icons:AnchorPartyFrames()
    else
        NS.useCompactPartyFrames = true
        NS.Icons:AnchorRaidFrames()
    end
end

function Diminish:PLAYER_ENTERING_WORLD()
    self:ToggleForZone()

    -- If both Diminish and sArena DR tracking is enabled for arena, then
    -- disable sArena tracking since they overlap each other
    if not self.sArenaDetectRan and self.currInstanceType == "arena" then
        if NS.db.unitFrames.arena.enabled then
            if LibStub and LibStub("AceAddon-3.0", true) then
                local _, sArena = pcall(function()
                     -- lambda so we can use ":" or else aceaddon bugs out
                    return LibStub("AceAddon-3.0"):GetAddon("sArena")
                end)

                if sArena and sArena.db.profile.drtracker.enabled then
                    sArena.db.profile.drtracker.enabled = false
                    sArena:RefreshConfig()
                end
                self.sArenaDetectRan = true
            end
        end
    end
end

function Diminish:PLAYER_TARGET_CHANGED()
    Timers:Refresh("target")
end

function Diminish:PLAYER_FOCUS_CHANGED()
    Timers:Refresh("focus")
end

function Diminish:ARENA_OPPONENT_UPDATE(unitID, status)
    if status == "seen" and not strfind(unitID, "pet") then
        if tonumber(strmatch(unitID, "%d+")) <= 5 then -- ignore arena6 and above for arena brawl
            Timers:Refresh(unitID)
        end
    end
end

function Diminish:GROUP_ROSTER_UPDATE()
    local members = min(GetNumGroupMembers(), 4)
    NS.Icons:AnchorRaidFrames(members) -- reanchor CompactRaidFrame if enabled
    NS.Icons:AnchorPartyFrames(members) -- reanchor PartyMemberFrame if enabled

    for i = 1, members do
        Timers:Refresh("party"..i)
    end
end

function Diminish:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Diminish:PLAYER_REGEN_DISABLED()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

do
    local COMBATLOG_OBJECT_REACTION_FRIENDLY = _G.COMBATLOG_OBJECT_REACTION_FRIENDLY
    local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER
    local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
    local bit_band = _G.bit.band
    local spellList = NS.spellList

    local GROUP_MEMBER = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY) -- , COMBATLOG_OBJECT_AFFILIATION_RAID

    function Diminish:COMBAT_LOG_EVENT_UNFILTERED()
        local _, eventType, _, srcGUID, _, _, _, destGUID, _, destFlags, _, spellID, _, _, auraType = CombatLogGetCurrentEventInfo()

        if auraType == "DEBUFF" then
            local category = spellList[spellID]
            if not category then return end

            if bit_band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then -- unit is player
                local isFriendly = bit_band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
                if not isFriendly and self.onlyFriendlyTracking then return end

                if isFriendly then
                    if not self.isWatchingFriendly then return end

                    if self.onlyPlayerWatchFriendly then
                        if destGUID ~= self.PLAYER_GUID  then return end
                    end

                    if self.onlyTrackingPartyForFriendly then
                        if bit_band(destFlags, GROUP_MEMBER) == 0 then return end -- or ~= 0 ?
                    end
                end

                if eventType == "SPELL_AURA_REMOVED" then
                    Timers:Insert(destGUID, srcGUID, category, spellID, isFriendly, false)
                elseif eventType == "SPELL_AURA_APPLIED" then
                    Timers:Insert(destGUID, srcGUID, category, spellID, isFriendly, true)
                elseif eventType == "SPELL_AURA_REFRESH" then
                    Timers:Update(destGUID, category, spellID, isFriendly, true)
                end
            end
        end

        if eventType == "UNIT_DIED" or eventType == "PARTY_KILL" then
            if self.currInstanceType ~= "arena" then
                if destGUID == self.PLAYER_GUID then
                    -- Delete ALL timers when player died
                    return Timers:ResetAll()
                end
                Timers:Remove(destGUID, false)
            end
        end
    end
end
