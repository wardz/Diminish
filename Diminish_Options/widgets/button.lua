local _, NS = ...
local Widgets = NS.Widgets

local function OnEnter(self)
    if self.tooltipText and not GameTooltip:IsForbidden() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
end

function Widgets:CreateButton(parent, text, tooltipText, func)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:GetFontString():SetPoint("CENTER", -1, 0)
    button:SetMotionScriptsWhileDisabled(true)
    button:RegisterForClicks("AnyUp")

    button:SetText(text)
    button:SetWidth(max(110, button:GetFontString():GetStringWidth() + 24))
    button.tooltipText = tooltipText

    button:SetScript("OnClick", func)
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", GameTooltip_Hide)

    return button
end
