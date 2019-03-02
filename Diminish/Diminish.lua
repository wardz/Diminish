local _, NS = ...

local Diminish = CreateFrame("Frame")
Diminish:RegisterEvent("PLAYER_LOGIN")
Diminish:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
end)

function Diminish:Debug(...)
    if false then print("|cFFFF0000[D]|r" .. format(...)) end
end

function Diminish:Info(...)
    if false then print("|cFFFF0000[I]|r" .. format(...)) end
end

function Diminish:Module(name, obj)

end

function Diminish:MergeDefaultSettings(src, dst)
    if type(src) ~= "table" then return {} end
    if type(dst) ~= "table" then dst = {} end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = self:CopyDefaults(v, dst[k])
        elseif type(v) ~= type(dst[k]) then
            dst[k] = v
        end
    end

    return dst
end

function Diminish:RemoveOldSettings(src, dst)
    for key, value in pairs(src) do
        if dst[key] == nil then
                src[key] = nil
        elseif type(value) == "table" then
            dst[key] = self:RemoveOldSettings(value, dst[key])
        end
    end

    return dst
end

function Diminish:Enable()
    -- reset all timers
    -- set/update CLEU watch variables
    -- register CLEU, trigger GROUP_ROSTER_UPDATE maybe

    self:Info("Enabled addon for zone %s.", self.currInstanceType)
end

function Diminish:Disable()
    self:UnregisterAllEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CVAR_UPDATE")
    -- timers reset all + guids

    self:Info("Disabled addon for zone %s.", self.currInstanceType)
end

function Diminish:GetProfile()
    return self.db, self.activeProfile
end

function Diminish:SetupSavedVariables()
    DiminishSV = next(DiminishSV or {}) and DiminishSV or {
        profileKeys = {},
        profiles = {},
    }

    local playerName = UnitName("player") .. "-" .. GetRealmName()
    local profile = DiminishSV.profileKeys[playerName]

    if not profile or not DiminishSV.profiles[profile] then
        -- Profile doesn't exist or is deleted, reset to default
        DiminishSV.profileKeys[playerName] = "Default"
        profile = "Default"
    end

    -- Copy any settings from default if they don't exist in current profile
    self:MergeDefaultSettings({
        [profile] = NS.DEFAULT_SETTINGS
    }, DiminishSV.profiles)

    self.db = DiminishSV.profiles[profile]
    self.activeProfile = profile

    -- Cleanup
    self:RemoveOldSettings(DiminishSV.profiles[profile], NS.DEFAULT_SETTINGS)
    self.SetupSavedVariables = nil
end
