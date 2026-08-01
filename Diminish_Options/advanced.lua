local _, NS = ...
local Panel = NS.Panel
local Widgets = NS.Widgets
local L = NS.L

Panel:CreateChildPanel("Advanced", function(panel)
    local title = Widgets:CreateHeader(panel, panel.name, false, "Customize the DR category text shown above icons.")

    local showCategoryText = Widgets:CreateCheckbox(panel, L.SHOWCATEGORYTEXT, L.SHOWCATEGORYTEXT_TOOLTIP, function(cb)
        DIMINISH_NS.db.showCategoryText = not DIMINISH_NS.db.showCategoryText
        DIMINISH_NS.Icons:OnFrameConfigChanged()
    end)
    showCategoryText:SetPoint("LEFT", title, 0, -60)
    showCategoryText:SetChecked(DIMINISH_NS.db.showCategoryText)

    local categoryEditboxes = {}
    local x, y = -130, 10

    for k, category in pairs(DIMINISH_NS.CATEGORIES) do
        categoryEditboxes[k] = Widgets:CreateEditbox(panel, (category .. ":"), "Change DR category text shown above icon.")
        categoryEditboxes[k]:SetPoint("TOPLEFT", y, x)
        categoryEditboxes[k]:SetText(DIMINISH_NS.db.abbreviations[category] or category)
        categoryEditboxes[k]:SetCursorPosition(0)

        local function SaveAbbreviation(self)
            local text = self:GetText()
            self:ClearFocus()
            self:ClearHighlightText()

            if text == nil or text == "" or text:len() > 40 then
                if DIMINISH_NS.db.abbreviations[category] then
                    DIMINISH_NS.db.abbreviations[category] = nil
                    self:SetText(category)
                    Widgets:ShowError(L.RESET)
                end
                DIMINISH_NS.Icons:OnFrameConfigChanged()
                return
            end

            DIMINISH_NS.db.abbreviations[category] = text
            DIMINISH_NS.Icons:OnFrameConfigChanged()
        end

        --categoryEditboxes[k]:SetScript("OnTextChanged", SaveAbbreviation)
        categoryEditboxes[k]:SetScript("OnEditFocusLost", SaveAbbreviation)
        categoryEditboxes[k]:SetScript("OnEnterPressed", SaveAbbreviation)
        categoryEditboxes[k]:SetScript("OnEscapePressed", SaveAbbreviation)

        if x <= -530 then
            x = -130
            y = y + 210
        else
            x = x - 50
        end
    end

    panel.refresh = function()
        showCategoryText:SetChecked(DIMINISH_NS.db.showCategoryText)

        for k, category in pairs(DIMINISH_NS.CATEGORIES) do
            if categoryEditboxes[k] then
                categoryEditboxes[k]:SetText(DIMINISH_NS.db.abbreviations[category] or category)
                categoryEditboxes[k]:SetCursorPosition(0)
            end
        end
    end
end)
