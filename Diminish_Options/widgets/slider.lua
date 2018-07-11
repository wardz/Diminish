local ADDON_NAME, NS = ...
local Widgets = NS.Widgets

local count = 0

local function OnValueChanged(self, value)
    local val = ceil(value)
    _G[self:GetName() .. "High"]:SetText(val)

    if self.callbackFunc and self.hasRefreshed then
        self.callbackFunc(self, val)
    end
    self.hasRefreshed = true -- only run callback after panel.refresh() has been triggered once after startup
end

function Widgets:CreateSlider(parent, text, tooltipText, minValue, maxValue, valueStep, func)
    local name = format("%sSlider%d", ADDON_NAME, count)

    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetSize(180, 15)
    slider:SetMinMaxValues(minValue or 1, maxValue or 100)
    slider:SetValueStep(valueStep or 1)
    slider.tooltipText = tooltipText
    slider.callbackFunc = func
    slider:SetScript("OnValueChanged", OnValueChanged)

    local label = _G[name .. "Text"]
    label:SetFontObject("GameFontNormalLeft")
    label:ClearAllPoints()
    label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 3)
    label:SetText(text)

    local value =  _G[name .. "High"]
    value:SetFontObject("GameFontHighlightSmall")
    value:ClearAllPoints()
    value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 3)

    _G[name .. "Low"]:SetText("")
    count = count + 1

    return slider
end
