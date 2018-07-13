local ADDON_NAME, NS = ...
local Widgets = {}
NS.Widgets = Widgets

-- Helper functions for Widgets

function Widgets:ToggleState(widget, state)
    if state then
        widget:Enable()
        if widget:IsObjectType("Slider") then
            widget:SetAlpha(1)
        end
    else
        widget:Disable()
        if widget:IsObjectType("Slider") then
            widget:SetAlpha(0.5) -- fade out slider when disabled, cba messing with textures
        end
    end
end

function Widgets:CopyTable(src, dest)
    if type(dest) ~= "table" then dest = {} end
    if type(src) == "table" then
        for k, v in pairs(src) do
            if type(v) == "table" then
                v = self:CopyTable(v, dest[k])
            end
            dest[k] = v
        end
    end
    return dest
end

function Widgets:ShowError(text)
    if not StaticPopupDialogs[ADDON_NAME .. "_ERRORMESSAGE"] then
        StaticPopupDialogs[ADDON_NAME .. "_ERRORMESSAGE"] = {
            button1 = OKAY or "Okay",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end

    StaticPopupDialogs[ADDON_NAME .. "_ERRORMESSAGE"].text = text
    StaticPopup_Show(ADDON_NAME .. "_ERRORMESSAGE")
end

function Widgets:RefreshWidgets(db, panel)
    local frames = panel.frames

    for setting, value in pairs(db) do
        if frames[setting] then
            if frames[setting].IsObjectType then
                if frames[setting]:IsObjectType("Slider") then
                    frames[setting]:SetValue(value)
                elseif frames[setting]:IsObjectType("CheckButton") then
                    frames[setting]:SetChecked(value)
                elseif frames[setting].items then -- phanx dropdown
                    frames[setting]:SetValue(value.name)
                end
            end
        end
    end
end

function Widgets.OnEnter(self)
    if self.tooltipText and not GameTooltip:IsForbidden() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
end
