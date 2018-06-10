local _, NS = ...
local Panel = NS.Panel
local Widgets = NS.Widgets
local L = NS.L

local function Refresh(self)
    local frames = self.frames
    local unit = self.unitID
    local unitFrameSettings = DIMINISH_NS.db.unitFrames[unit]

    if not unitFrameSettings.enabled then
        frames.enabled.labelText:SetTextColor(1, 0, 0, 1)
    else
        frames.enabled.labelText:SetTextColor(1, 1, 1, 1)
    end

    -- Refresh value of all widgets except zones/categories
    for setting, value in pairs(unitFrameSettings) do
        if setting ~= "zones" and setting ~= "categories" then
            if frames[setting] then
                if frames[setting]:IsObjectType("Slider") then
                    frames[setting]:SetValue(value)
                elseif frames[setting]:IsObjectType("CheckButton") then
                    frames[setting]:SetChecked(value)
                end
            end
        end
    end

    -- Refresh categories
    for k, category in pairs(DIMINISH_NS.CATEGORIES) do
        if frames.categories[k] then
            if unitFrameSettings.disabledCategories[category] then
                frames.categories[k]:SetChecked(false)
            end
        end
    end

    -- Refresh zones
    if frames.zones then
        for instance, value in pairs(unitFrameSettings.zones) do
            if frames.zones[instance] then
                frames.zones[instance]:SetChecked(value)
            end
        end
    end
end

do
    local zones = {
        [L.ZONE_ARENA] = "arena", -- localized name, instanceType
        [L.ZONE_BATTLEGROUNDS] = "pvp",
        [L.ZONE_OUTDOORS] = "none"
        -- Note: we don't add this directly in localization.lua because
        -- curse locale export doesn't support it
    }

    -- TODO: probably want to reuse frames here
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
                else
                    frames.enabled.labelText:SetTextColor(1 ,1, 1, 1)
                end

                DIMINISH_NS.Diminish:ToggleForZone()

                if unit == "party" then
                    DIMINISH_NS.Icons:AnchorPartyFrames()
                end
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


            frames.iconSize = Widgets:CreateSlider(panel, L.ICONSIZE, L.ICONSIZE_TOOLTIP, 10, 80, 1, function(frame, value)
                db.iconSize = value
                --DIMINISH_NS.Timers:ResetAll()
                DIMINISH_NS.Icons:OnFrameConfigChanged()
                --NS.TestMode:UpdateAnchors()
            end)
            frames.iconSize:SetPoint("LEFT", frames.growLeft, 10, -50)


            frames.iconPadding = Widgets:CreateSlider(panel, L.ICONPADDING, L.ICONPADDING_TOOLTIP, 0, 40, 1, function(frame, value)
                db.iconPadding = value
                DIMINISH_NS.Icons:OnFrameConfigChanged()
            end)
            frames.iconPadding:SetPoint("LEFT", frames.iconSize, 0, -70)


            -------------------------------------------------------------------

            do
                local subCategories = Widgets:CreateSubHeader(panel, L.HEADER_CATEGORIES)
                subCategories:SetPoint("TOPRIGHT", -64, -50)

                frames.categories = {}
                local x = -60
                local dbCategories = NS.GetDBProxy("unitFrames", unit, "disabledCategories")

                for k, category in pairs(DIMINISH_NS.CATEGORIES) do
                    frames.categories[k] = Widgets:CreateCheckbox(panel, category, L.CATEGORIES_TOOLTIP, function(self)
                        dbCategories[category] = self:GetChecked() == false and true or false
                    end)

                    frames.categories[k]:SetPoint("LEFT", subCategories, 10, x)
                    frames.categories[k]:SetChecked(true)
                    x = x - 30
                end
            end

            -------------------------------------------------------------------

            if unit ~= "arena" then
                local subZones = Widgets:CreateSubHeader(panel, L.HEADER_ZONE)
                subZones:SetPoint("LEFT", 16, -100)

                frames.zones = {}
                local x = -60
                local dbZones = NS.GetDBProxy("unitFrames", unit, "zones")

                for label, instance in pairs(zones) do
                    frames.zones[instance] = Widgets:CreateCheckbox(panel, label, L.ZONES_TOOLTIP, function(self)
                        dbZones[instance] = self:GetChecked() and true or false

                        DIMINISH_NS.Diminish:ToggleForZone()
                    end)

                    frames.zones[instance]:SetPoint("LEFT", subZones, 10, x)
                    x = x - 30
                end
            end

            local testBtn = Widgets:CreateButton(panel, L.TEST, L.TEST_TOOLTIP, function(btn)
                if not InCombatLockdown() then
                    btn:SetText(btn:GetText() == L.TEST and L.STOP or L.TEST)
                    NS.TestMode:Test()
                end
            end)
            testBtn:SetPoint("BOTTOMRIGHT", panel, -15, 15)
        end)
    end
end
