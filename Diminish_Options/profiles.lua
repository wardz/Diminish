local _, NS = ...
local Panel = NS.Panel
local Widgets = NS.Widgets
local L = NS.L

local Dropdown = LibStub("PhanxConfig-Dropdown")

local profiles = {}

Panel:CreateChild("Profiles", function(panel)
    Widgets:CreateHeader(panel, panel.name, false, L.HEADER_PROFILES)

    for k, v in pairs(DiminishDB.profileKeys) do
        if v ~= "Default" and v ~= DIMINISH_NS.activeProfile then
            profiles[#profiles + 1] = { value = v, text = v }
        end
    end


    local selectProfile = Dropdown.CreateDropdown(panel, L.SELECTPROFILE, L.SELECTPROFILE_TOOLTIP, profiles)
    selectProfile:SetPoint("TOPLEFT", panel, 30, -80)
    selectProfile:SetWidth(200)


    local copyBtn = Widgets:CreateButton(panel, L.COPY, L.COPY_TOOLTIP, function(btn)
        local value = selectProfile:GetValue()
        if not value or value == EMPTY then return end

        if DiminishDB.profileKeys[NS.PLAYER_NAME] == NS.PLAYER_NAME then
            -- set current values to nil so CopyDefaults() works correctly
            -- (could add an extra copytable function but rather just reuse this)
            DiminishDB.profiles[NS.PLAYER_NAME] = nil
        end

        DIMINISH_NS.CopyDefaults({
            [NS.PLAYER_NAME] = DiminishDB.profiles[value]
        }, DiminishDB.profiles)

        DiminishDB.profileKeys[NS.PLAYER_NAME] = NS.PLAYER_NAME

        DIMINISH_NS.db = DiminishDB.profiles[NS.PLAYER_NAME]
        DIMINISH_NS.activeProfile = NS.PLAYER_NAME

        selectProfile:SetValue(nil)
        panel.refresh()
        DIMINISH_NS.Icons:OnFrameConfigChanged()

        if NS.TestMode:IsTestingOrAnchoring() then
            NS.TestMode:HideAnchors()
            NS.TestMode:Test(true) -- hide timers + arena/party frames
        end
    end)
    copyBtn:SetPoint("RIGHT", selectProfile, 75, -8)
    copyBtn:SetWidth(70)


    local deleteBtn = Widgets:CreateButton(panel, L.DELETE, L.DELETE_TOOLTIP, function(btn)
        local value = selectProfile:GetValue()
        if not value or value == EMPTY then return end
        DiminishDB.profileKeys[value] = nil
        DiminishDB.profiles[value] = nil

        for i, profile in ipairs(profiles) do
            for k, v in pairs(profile) do
                if v == value then
                    tremove(profiles, i)
                    break
                end
            end
        end

        selectProfile:SetList(profiles)
        selectProfile:SetValue(nil)
    end)
    deleteBtn:SetPoint("LEFT", copyBtn, 75, 0)
    deleteBtn:SetWidth(70)

    -------------------------------------------------------------------

    local resetBtn = Widgets:CreateButton(panel, L.RESET, L.RESET_TOOLTIP, function(btn)
        DiminishDB.profileKeys[NS.PLAYER_NAME] = "Default"
        if DiminishDB.profiles[NS.PLAYER_NAME] then
            DiminishDB.profiles[NS.PLAYER_NAME] = nil
        end

        DIMINISH_NS.db = DiminishDB.profiles["Default"]
        DIMINISH_NS.activeProfile = "Default"
        panel.refresh()

        if NS.TestMode:IsTestingOrAnchoring() then
            NS.TestMode:HideAnchors()
            NS.TestMode:Test(true)
        end
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    resetBtn:SetPoint("LEFT", selectProfile, 0, -100)


    local profileText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    profileText:SetJustifyH("LEFT")
    profileText:SetPoint("TOPLEFT", resetBtn, 0, 20)


    panel.refresh = function()
        profileText:SetText(format(L.CURRENT_PROFILE, DiminishDB.profileKeys[NS.PLAYER_NAME]))
    end
end)
