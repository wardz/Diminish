local _, NS = ...
local Panel = NS.Panel
local Widgets = NS.Widgets
local L = NS.L

local Dropdown = LibStub("PhanxConfig-Dropdown")
local profiles = {}

local function DropdownRemove(value)
    for i, profile in ipairs(profiles) do
        for k, v in pairs(profile) do
            if v == value then
                tremove(profiles, i)
                break
            end
        end
    end
end

local function DropdownInsert(value, text)
    profiles[#profiles + 1] = { value = value, text = text or value }
end

Panel:CreateChild(L.PROFILES, function(panel)
    Widgets:CreateHeader(panel, panel.name, false, L.HEADER_PROFILES)

    for k, v in pairs(DiminishDB.profiles) do
        if k ~= "Default" and k ~= DIMINISH_NS.activeProfile then
            profiles[#profiles + 1] = { value = k, text = k }
        end
    end


    local selectProfile = Dropdown.CreateDropdown(panel, L.SELECTPROFILE, L.SELECTPROFILE_TOOLTIP, profiles)
    selectProfile:SetPoint("TOPLEFT", panel, 30, -80)
    selectProfile:SetWidth(200)


    local shareBtn = Widgets:CreateButton(panel, L.USEPROFILE, L.USEPROFILE_TOOLTIP, function(btn)
        local value = selectProfile:GetValue()
        if not value or value == EMPTY then return end
        if DIMINISH_NS.activeProfile == value then return end

        DiminishDB.profileKeys[NS.PLAYER_NAME] = value

        DIMINISH_NS.db = DiminishDB.profiles[value]
        DIMINISH_NS.activeProfile = value

        selectProfile:SetValue(nil)
        panel.refresh()
        DIMINISH_NS.Icons:OnFrameConfigChanged()

        if NS.TestMode:IsTestingOrAnchoring() then
            NS.TestMode:HideAnchors()
            NS.TestMode:Test(true) -- hide timers + arena/party frames
        end
    end)
    shareBtn:SetPoint("RIGHT", selectProfile, 75, -8)
    shareBtn:SetWidth(70)


    local copyBtn = Widgets:CreateButton(panel, L.COPY, L.COPY_TOOLTIP, function(btn)
        local value = selectProfile:GetValue()
        if not value or value == EMPTY then return end
        if DIMINISH_NS.activeProfile == value then return end

        if DiminishDB.profileKeys[NS.PLAYER_NAME] == NS.PLAYER_NAME then
            -- set current values to nil so CopyDefaults() works correctly
            -- (could add an extra copytable function but rather just reuse CopyDefaults)
            DiminishDB.profiles[NS.PLAYER_NAME] = nil
        end

        -- TODO: should create new profile if using default, or copy directly to Default?
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
            NS.TestMode:Test(true)
        end
    end)
    copyBtn:SetPoint("LEFT", shareBtn, 75, 0)
    copyBtn:SetWidth(70)


    local deleteBtn = Widgets:CreateButton(panel, L.DELETE, L.DELETE_TOOLTIP, function(btn)
        local value = selectProfile:GetValue()
        if not value or value == EMPTY then return end
        if DIMINISH_NS.activeProfile == value then return end
        DiminishDB.profileKeys[value] = nil
        DiminishDB.profiles[value] = nil

        DropdownRemove(value)
        selectProfile:SetList(profiles) -- TODO: needeD?
        selectProfile:SetValue(nil)
    end)
    deleteBtn:SetPoint("LEFT", copyBtn, 75, 0)
    deleteBtn:SetWidth(70)


    -------------------------------------------------------------------

    local editBox = Widgets:CreateEditbox(panel, L.NEWPROFILE, L.NEWPROFILE_TOOLTIP)
    editBox:SetPoint("LEFT", selectProfile, 8, -80)
    editBox:SetScript("OnEditFocusGained", function()
        if DIMINISH_NS.activeProfile ~= NS.PLAYER_NAME then
            if not DiminishDB.profiles[value] then
                editBox:SetText(NS.PLAYER_NAME or "")
            end
        end
    end)

    local editOkay = Widgets:CreateButton(panel, OKAY or "Okay", nil, function(btn)
        local value = editBox:GetText()
        if not value or value == "" then return end

        if DiminishDB.profiles[value] then
            return print("Profile already exists")
        end

        DiminishDB.profileKeys[NS.PLAYER_NAME] = value

        DIMINISH_NS.CopyDefaults({
            [value] = DIMINISH_NS.db
        }, DiminishDB.profiles)

        DIMINISH_NS.db = DiminishDB.profiles[value]
        DIMINISH_NS.activeProfile = value
        DIMINISH_NS.Icons:OnFrameConfigChanged()

        panel.refresh()
        editBox:SetText("")
        editBox:ClearFocus()
        DropdownInsert(value)
    end)
    editOkay:SetPoint("RIGHT", editBox, 75, 0)
    editOkay:SetWidth(70)

    -------------------------------------------------------------------

    local resetBtn = Widgets:CreateButton(panel, L.RESETPROFILE, L.RESETPROFILE_TOOLTIP, function(btn)
        if DiminishDB.profiles[DIMINISH_NS.activeProfile] then
            DiminishDB.profiles[DIMINISH_NS.activeProfile] = nil
        end

        DiminishDB.profileKeys[NS.PLAYER_NAME] = "Default"
        DIMINISH_NS.activeProfile = "Default"
        DIMINISH_NS.db = DIMINISH_NS.DEFAULT_SETTINGS

        if NS.TestMode:IsTestingOrAnchoring() then
            NS.TestMode:HideAnchors()
            NS.TestMode:Test(true)
        end
        DIMINISH_NS.Icons:OnFrameConfigChanged()
        panel.refresh()
    end)
    resetBtn:SetPoint("LEFT", editBox, 0, -100)


    local profileText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    profileText:SetJustifyH("LEFT")
    profileText:SetPoint("TOPLEFT", resetBtn, 0, 25)
    profileText:SetFont(profileText:GetFont(), 13)

    -------------------------------------------------------------------

    panel.refresh = function()
        profileText:SetText(format(L.CURRENT_PROFILE, DiminishDB.profileKeys[NS.PLAYER_NAME]))
    end
end)
