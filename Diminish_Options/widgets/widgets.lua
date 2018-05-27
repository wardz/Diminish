local _, NS = ...
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
