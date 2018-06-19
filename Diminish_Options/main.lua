local _, NS = ...
local Widgets = NS.Widgets
local Panel = NS.Panel
local TestMode = NS.TestMode
local L = NS.L

NS.PLAYER_NAME = UnitName("player") .. "-" .. GetRealmName()

NS.unitFrames = {
    [L.PLAYER] = "player", -- localized, unlocalized unitID
    [L.TARGET] = "target",
    [L.FOCUS] = "focus",
    [L.PARTY] = "party",
    [L.ARENA] = "arena",
}

NS.CreateNewProfile = function()
    if DIMINISH_NS.activeProfile == "Default" then
        DiminishDB.profileKeys[NS.PLAYER_NAME] = NS.PLAYER_NAME

        DIMINISH_NS.CopyDefaults({
            [NS.PLAYER_NAME] = DIMINISH_NS.db
        }, DiminishDB.profiles)

        DIMINISH_NS.db = DiminishDB.profiles[NS.PLAYER_NAME]
        DIMINISH_NS.activeProfile = NS.PLAYER_NAME
    end
end

-- Proxy table for diminish savedvariables
-- Spaghetti code inc, im just too lazy to rewrite all of this
NS.GetDBProxy = function(key1, key2, key3)
    return setmetatable({}, {
        __index = function(self, key)
            if key3 then -- proxy for nested tables.
                return DIMINISH_NS.db[key1][key2][key3][key]
            elseif key2 then
                return DIMINISH_NS.db[key1][key2][key]
            elseif key1 then
                return DIMINISH_NS.db[key1][key]
            else
                return DIMINISH_NS.db[key]
            end
        end,

        __newindex = function(self, key, value)
            -- If we still use Default profile and change a DB option,
            -- create a new profile for the current player
            NS.CreateNewProfile()

            local tbl
            if key3 then
                tbl = DIMINISH_NS.db[key1][key2][key3]
            elseif key2 then
                tbl = DIMINISH_NS.db[key1][key2]
            elseif key1 then
                tbl = DIMINISH_NS.db[key1]
            else
                tbl = DIMINISH_NS.db
            end
            tbl[key] = value
        end,
    })
end

function Panel:Setup()
    local frames = self.frames
    local db = NS.GetDBProxy()

    local notes = GetAddOnMetadata(self.name, "Notes-" .. GetLocale()) or GetAddOnMetadata(self.name, "Notes")
    Widgets:CreateHeader(self, self.name, GetAddOnMetadata("Diminish", "Version"), notes)

    local subCooldown = Widgets:CreateSubHeader(self, L.HEADER_COOLDOWN)
    subCooldown:SetPoint("TOPLEFT", 16, -50)


    frames.displayMode = Widgets:CreateCheckbox(self, L.DISPLAYMODE, L.DISPLAYMODE_TOOLTIP, function(cb)
        db.displayMode = cb:GetChecked() and "ON_AURA_START" or "ON_AURA_END"
    end)
    frames.displayMode:SetPoint("LEFT", subCooldown, 10, -70)


    frames.timerSwipe = Widgets:CreateCheckbox(self, L.TIMERSWIPE, L.TIMERSWIPE_TOOLTIP, function()
        db.timerSwipe = not db.timerSwipe
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    frames.timerSwipe:SetPoint("LEFT", frames.displayMode, 0, -40)


    frames.timerText = Widgets:CreateCheckbox(self, L.TIMERTEXT, L.TIMERTEXT_TOOLTIP, function()
        Widgets:ToggleState(frames.timerColors, frames.timerText:GetChecked())
        Widgets:ToggleState(frames.timerTextSize, frames.timerText:GetChecked())

        db.timerText = not db.timerText
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    frames.timerText:SetPoint("LEFT", frames.timerSwipe, 0, -40)


    frames.timerColors = Widgets:CreateCheckbox(self, L.TIMERCOLORS, L.TIMERCOLORS_TOOLTIP, function()
        db.timerColors = not db.timerColors
        DIMINISH_NS.Icons:OnFrameConfigChanged()
        DIMINISH_NS.Timers:ResetAll()
    end)
    frames.timerColors:SetPoint("LEFT", frames.timerText, 15, -40)


    frames.timerTextSize = Widgets:CreateSlider(self, L.TIMERTEXTSIZE, L.TIMERTEXTSIZE_TOOLTIP, 7, 35, 1, function(_, value)
        db.timerTextSize = value
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    frames.timerTextSize:SetPoint("LEFT", frames.timerColors, 10, -50)

    -------------------------------------------------------------------

    local subMisc = Widgets:CreateSubHeader(self, L.HEADER_MISC)
    subMisc:SetPoint("TOPRIGHT", -64, -50)


    frames.showCategoryText = Widgets:CreateCheckbox(self, L.SHOWCATEGORYTEXT, L.SHOWCATEGORYTEXT_TOOLTIP, function(cb)
        db.showCategoryText = not db.showCategoryText
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    frames.showCategoryText:SetPoint("RIGHT", -225, 160)


    frames.trackNPCs = Widgets:CreateCheckbox(self, L.TRACKNPCS, L.TRACKNPCS_TOOLTIP, function()
        db.trackNPCs = not db.trackNPCs

        for _, unit in pairs({ "target", "focus" }) do
            local cfg = db.unitFrames[unit]
            if db.trackNPCs then
                cfg.disabledCategories[DIMINISH_NS.CATEGORIES.TAUNT] = false
            elseif not db.trackNPCs then
                cfg.disabledCategories[DIMINISH_NS.CATEGORIES.TAUNT] = true
            end

            cfg.zones.party = db.trackNPCs
            cfg.zones.scenario = db.trackNPCs
            cfg.zones.raid = db.trackNPCs
        end
        DIMINISH_NS.Diminish:ToggleForZone()
    end)
    frames.trackNPCs:SetPoint("LEFT", frames.showCategoryText, 0, -40)

    frames.spellBookTextures = Widgets:CreateCheckbox(self, L.SPELLBOOKTEXTURES, L.SPELLBOOKTEXTURES_TOOLTIP, function()
        db.spellBookTextures = not db.spellBookTextures
    end)
    frames.spellBookTextures:SetPoint("LEFT", frames.trackNPCs, 0, -40)

    frames.colorBlind = Widgets:CreateCheckbox(self, L.COLORBLIND, L.COLORBLIND_TOOLTIP, function()
        db.colorBlind = not db.colorBlind
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    frames.colorBlind:SetPoint("LEFT", frames.spellBookTextures, 0, -40)


    local textures = {
        { value = "Interface\\BUTTONS\\UI-Quickslot-Depress", text = L.DEFAULT },
        -- { value = "Interface\\COMMON\\WhiteIconFrame", text = "Clean" },
        { value = "Interface\\BUTTONS\\WHITE8X8", text = L.TEXTURE_BRIGHT },
        { value = "", text = L.TEXTURE_NONE },
    }

    frames.borderTexture = LibStub("PhanxConfig-Dropdown").CreateDropdown(self, L.SELECTBORDER, L.SELECTBORDER_TOOLTIP, textures)
    frames.borderTexture:SetPoint("LEFT", frames.colorBlind, 7, -55)
    frames.borderTexture:SetWidth(180)
    frames.borderTexture.OnValueChanged = function(self, value)
        if not value or value == EMPTY then return end
        db.borderTexture = value
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end

    -------------------------------------------------------------------

    local tip = self:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    tip:SetJustifyH("LEFT")
    tip:SetText(L.TARGETTIP)
    tip:SetPoint("CENTER", self, 0, -220)
    tip:Hide()


    -- Show drag anchors
    local unlock = Widgets:CreateButton(self, L.UNLOCK, L.UNLOCK_TOOLTIP, function(btn)
        if InCombatLockdown() then
            return print(L.COMBATLOCKDOWN_ERROR)
        end

        if btn:GetText() == L.UNLOCK then
            btn:SetText(L.STOP)
            tip:Show()
            TestMode:ShowAnchors()
        else
            TestMode:HideAnchors()
            btn:SetText(L.UNLOCK)
            tip:Hide()
        end
    end)
    unlock:SetPoint("BOTTOMLEFT", self, 15, 10)
    unlock:SetSize(200, 25)


    -- Test mode for timers
    local testBtn = Widgets:CreateButton(self, L.TEST, L.TEST_TOOLTIP, function(btn)
        if not InCombatLockdown() then
            btn:SetText(btn:GetText() == L.TEST and L.STOP or L.TEST)
            tip:SetShown(btn:GetText() ~= L.TEST)
            TestMode:Test()
        else
            print("Diminish: " .. L.COMBATLOCKDOWN_ERROR)
        end
    end)
    testBtn:SetSize(200, 25)
    --testBtn:SetAttribute("type", "macro")
    --testBtn:SetAttribute("macrotext", "/target [@player]\n/focus [@player]\n/diminishtest")
    testBtn:SetPoint("BOTTOMRIGHT", self, -15, 10)
end

function Panel:refresh()
    local frames = self.frames

    -- Refresh value of all widgets
    for setting, value in pairs(DIMINISH_NS.db) do
        if frames[setting] then
            if frames[setting]:IsObjectType("Slider") then
                frames[setting]:SetValue(value)
            elseif frames[setting]:IsObjectType("CheckButton") then
                if value == "ON_AURA_END" then
                    value = false
                elseif value == "ON_AURA_START" then
                    value = true
                end
                frames[setting]:SetChecked(value)
            elseif frames[setting].items then -- phanx dropdown
                frames[setting]:SetValue(value)
            end
        end
    end

    -- Disable rest of timer options if timer countdown is not checked
    Widgets:ToggleState(frames.timerColors, frames.timerText:GetChecked())
    Widgets:ToggleState(frames.timerTextSize, frames.timerText:GetChecked())
end

SLASH_DIMINISH1 = "/diminish"
SlashCmdList.DIMINISH = function()
    InterfaceOptionsFrame_OpenToCategory(Panel)
    InterfaceOptionsFrame_OpenToCategory(Panel) -- double to fix blizz bug
end
