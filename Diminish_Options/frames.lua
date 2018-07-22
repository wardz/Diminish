local _, NS = ...
local Panel = NS.Panel
local Widgets = NS.Widgets
local L = NS.L

local zones = {
    [L.ZONE_ARENA] = "arena", -- localized name, instanceType
    [L.ZONE_BATTLEGROUNDS] = "pvp",
    [L.ZONE_OUTDOORS] = "none",
    [L.ZONE_DUNGEONS] = { "party", "raid", "scenario" },
}

local function Refresh(self)
    local frames = self.frames
    local unit = self.unitID
    local unitFrameSettings = DIMINISH_NS.db.unitFrames[unit]

    if not unitFrameSettings.enabled then
        frames.enabled.labelText:SetTextColor(1, 0, 0, 1)
        frames.testBtn:Disable()
    else
        frames.enabled.labelText:SetTextColor(1, 1, 1, 1)
        frames.testBtn:Enable()
    end

    Widgets:RefreshWidgets(unitFrameSettings, self)

    -- Refresh categories
    for k, category in pairs(DIMINISH_NS.CATEGORIES) do
        if frames.categories[k] then
            frames.categories[k]:SetChecked(not unitFrameSettings.disabledCategories[category])
        end
    end

    -- Refresh zones
    if frames.zones then
        for label, instance in pairs(zones) do
            if frames.zones[label] then
                if type(instance) == "table" then
                    for i = 1, #instance do
                        frames.zones[label]:SetChecked(unitFrameSettings.zones[instance[i]])
                        break -- if first is true or false, then all other is same value
                    end
                else
                    frames.zones[label]:SetChecked(unitFrameSettings.zones[instance])
                end
            end
        end

        -- Toggle widgets for taunt/zone dungeon depending on if PvE mode is enabled
        if frames.zones[L.ZONE_DUNGEONS] then
            if DIMINISH_NS.db.trackNPCs then
                frames.zones[L.ZONE_DUNGEONS]:Enable()
                frames.categories.TAUNT:Enable()
            else
                frames.zones[L.ZONE_DUNGEONS]:Disable()
                frames.categories.TAUNT:Disable()
            end
        end
    end
end

-- TODO: reuse frames
for unitFrame, unit in pairs(NS.unitFrames) do
    Panel:CreateChild(unitFrame, function(panel)
        Widgets:CreateHeader(panel, unitFrame, false, format(L.HEADER_UNITFRAME, unitFrame))
        panel.unitID = unit
        panel.refresh = Refresh

        local frames = panel.frames
        local db = NS.GetDBProxy("unitFrames", unit)

        local subVisuals = Widgets:CreateSubHeader(panel, L.HEADER_ICONS)
        subVisuals:SetPoint("TOPLEFT", 16, -50)


        frames.enabled = Widgets:CreateCheckbox(panel, L.ENABLED, L.ENABLED_TOOLTIP, function()
            db.enabled = not db.enabled
            if not db.enabled then
                frames.enabled.labelText:SetTextColor(1, 0, 0, 1)
                frames.testBtn:Disable()
            else
                frames.enabled.labelText:SetTextColor(1 ,1, 1, 1)
                frames.testBtn:Enable()
            end

            DIMINISH_NS.Diminish:ToggleForZone()
        end)
        frames.enabled:SetPoint("LEFT", subVisuals, 10, -70)

        if unit == "target" or unit == "focus" then
            frames.watchFriendly = Widgets:CreateCheckbox(panel, L.WATCHFRIENDLY, L.WATCHFRIENDLY_TOOLTIP, function()
                db.watchFriendly = not db.watchFriendly
                DIMINISH_NS.Diminish:ToggleForZone()
            end)
            frames.watchFriendly:SetPoint("LEFT", frames.enabled, 0, -40)
        end


        frames.growLeft = Widgets:CreateCheckbox(panel, L.GROWLEFT, L.GROWLEFT_TOOLTIP, function()
            db.growLeft = not db.growLeft
            DIMINISH_NS.Icons:OnFrameConfigChanged()
            if NS.TestMode:IsTestingOrAnchoring() then
                NS.TestMode:HideAnchors()
            end
        end)

        if frames.watchFriendly then
            frames.growLeft:SetPoint("LEFT", frames.watchFriendly, 0, -40)
        else
            frames.growLeft:SetPoint("LEFT", frames.enabled, 0, -40)
        end

        frames.anchorUIParent = Widgets:CreateCheckbox(panel, L.ANCHORUIPARENT, L.ANCHORUIPARENT_TOOLTIP, function()
            db.anchorUIParent = not db.anchorUIParent

            DIMINISH_NS.Icons:CreateUIParentOffsets(db, unit)
            DIMINISH_NS.Icons:OnFrameConfigChanged() -- reanchors from UIParent to UnitFrame or vice versa
            DIMINISH_NS.Diminish:GROUP_ROSTER_UPDATE()
            if NS.TestMode:IsTestingOrAnchoring() then
                NS.TestMode:HideAnchors()
            end
        end)
        frames.anchorUIParent:SetPoint("LEFT", frames.growLeft, 0, -40)


        frames.iconSize = Widgets:CreateSlider(panel, L.ICONSIZE, L.ICONSIZE_TOOLTIP, 10, 80, 1, function(frame, value)
            db.iconSize = value
            DIMINISH_NS.Icons:OnFrameConfigChanged()
        end)
        frames.iconSize:SetPoint("LEFT", frames.anchorUIParent, 10, -55)


        frames.iconPadding = Widgets:CreateSlider(panel, L.ICONPADDING, L.ICONPADDING_TOOLTIP, 0, 40, 1, function(frame, value)
            db.iconPadding = value
            DIMINISH_NS.Icons:OnFrameConfigChanged()
        end)
        frames.iconPadding:SetPoint("LEFT", frames.iconSize, 0, -50)


        -------------------------------------------------------------------

        do
            local subCategories = Widgets:CreateSubHeader(panel, L.HEADER_CATEGORIES)
            if unit ~= "arena" then
                subCategories:SetPoint("LEFT", 16, -100)
            else
                subCategories:SetPoint("TOPRIGHT", -64, -50)
            end

            frames.categories = {}
            local x, y = -60, 10
            local dbCategories = NS.GetDBProxy("unitFrames", unit, "disabledCategories")

            local i = 1
            for k, category in pairs(DIMINISH_NS.CATEGORIES) do
                local continue = true
                if category == DIMINISH_NS.CATEGORIES.TAUNT and unit ~= "focus" and unit ~= "target" then
                    -- only show Taunt for focus/target panel
                    continue = false
                end

                if continue then
                    frames.categories[k] = Widgets:CreateCheckbox(panel, category, L.CATEGORIES_TOOLTIP, function(self)
                        dbCategories[category] = self:GetChecked() == false and true or false
                    end)

                    frames.categories[k]:SetPoint("LEFT", subCategories, y, x)
                    frames.categories[k]:SetChecked(true)
                    x = x - 30
                    i = i + 1

                    if i > (unit == "arena" and 3 or 4) then
                        i = 1
                        x = -60
                        y = y + 120
                    end
                end
            end
        end

        -------------------------------------------------------------------

        if unit ~= "arena" then
            local subZones = Widgets:CreateSubHeader(panel, L.HEADER_ZONE)
            subZones:SetPoint("TOPRIGHT", -64, -50)

            frames.zones = {}
            local x = -60
            local dbZones = NS.GetDBProxy("unitFrames", unit, "zones")

            for label, instance in pairs(zones) do
                local continue = true
                if label == L.ZONE_DUNGEONS and unit ~= "focus" and unit ~= "target" then
                    -- only show L.ZONE_DUNGEONS for focus/target panel for now
                    continue = false
                end

                if continue then
                    frames.zones[label] = Widgets:CreateCheckbox(panel, label, L.ZONES_TOOLTIP, function(self)
                        if type(instance) == "table" then
                            for i = 1, #instance do
                                dbZones[instance[i]] = self:GetChecked() and true or false
                            end
                        else
                            dbZones[instance] = self:GetChecked() and true or false
                        end

                        DIMINISH_NS.Diminish:ToggleForZone()
                    end)

                    frames.zones[label]:SetPoint("LEFT", subZones, 10, x)
                    x = x - 30
                end
            end
        end

        frames.testBtn = Widgets:CreateButton(panel, L.TEST, L.TEST_TOOLTIP, function(btn)
            if InCombatLockdown() or InActiveBattlefield() or IsActiveBattlefieldArena() then
                return Widgets:ShowError(L.COMBATLOCKDOWN_ERROR)
            end
            btn:SetText(btn:GetText() == L.TEST and L.STOP or L.TEST)
            NS.TestMode:Test()
        end)
        frames.testBtn:SetPoint("BOTTOMRIGHT", panel, -15, 15)


        frames.resetPosBtn = Widgets:CreateButton(panel, L.RESETPOS, L.RESETPOS_TOOLTIP, function(btn)
            local defaults = DIMINISH_NS.DEFAULT_SETTINGS.unitFrames[unit]
            db.offsetY = defaults.offsetY
            db.offsetX = defaults.offsetX
            db.growLeft = defaults.growLeft
            db.offsetsY = nil
            db.offsetsX = nil

            DIMINISH_NS.Icons:OnFrameConfigChanged()
            if NS.TestMode:IsTestingOrAnchoring() then
                NS.TestMode:HideAnchors()
                NS.TestMode:Test(true)
            end
        end)
        frames.resetPosBtn:SetPoint("BOTTOMRIGHT", frames.testBtn, -120, 0)
    end)
end
