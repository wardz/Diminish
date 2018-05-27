local ADDON_NAME, NS = ...
local Widgets = NS.Widgets
local L = NS.L

local count = 0

local function OnValueChanged(self, value)
    local val = ceil(value)
    _G[self:GetName() .. "Text"]:SetFormattedText("%s (%d)", self.titleText, val)

    if self.callbackFunc and self.hasRefreshed then
        self.callbackFunc(self, val)
    end
    self.hasRefreshed = true -- only run callback after panel.refresh() has been triggered once
end

function Widgets:CreateSlider(parent, text, tooltipText, minValue, maxValue, valueStep, func)
    local name = format("%sSlider%d", ADDON_NAME, count)

    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetWidth(160)
    slider:SetMinMaxValues(minValue or 1, maxValue or 100)
    slider:SetValueStep(valueStep or 1)
    slider.tooltipText = tooltipText
    slider.titleText = text
    slider.callbackFunc = func
    slider:SetScript("OnValueChanged", OnValueChanged)

    _G[name .. "Text"]:SetText(text)
    _G[name .. "Low"]:SetText(L.SLIDER_LOW)
    _G[name .. "High"]:SetText(L.SLIDER_HIGH)

    count = count + 1
    return slider
end
