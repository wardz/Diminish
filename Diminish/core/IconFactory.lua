local IconFactory = {}
local PoolManager = {}

function IconFactory:New(globalConfig, frameConfig)
    local frame, isNew, index = PoolManager:AcquireFrame()
    frame:SetSize(frameConfig.iconSize, frameConfig.iconSize)

    if isNew then
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetAllPoints(frame)
        frame.icon:SetDrawLayer("ARTWORK", 7)
        frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        frame.cooldown = self:CreateCooldownFrame(frame, index)
        frame.border = self:CreateBorder(frame)
        frame.categoryLabel = self:CreateCategoryLabel(frame)
        frame.indicatorBorder, frame.indicatorText = self:CreateIndicators(frame)

        frame.countdown = frame.cooldown:GetRegions()
        frame.countdown:SetFont(frame.countdown:GetFont(), frameConfig.timerTextSize, globalConfig.timerTextOutline)

        self:SetupMasqueForIcon(frame)
    end

    -- if not isnew:
    -- update countdown font
    -- update parent
    -- update colorblind mode
    -- update category text & set shown

    return frame
end

function IconFactory:CreateCooldownFrame(parent, index)
    local cooldown = CreateFrame("Cooldown", "DiminishIcon"..index, parent, "CooldownFrameTemplate")
    cooldown:SetAllPoints(parent)
    cooldown:SetHideCountdownNumbers(not db.timerText)
    cooldown:SetDrawSwipe(db.timerSwipe)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(false)
    cooldown:SetSwipeColor(0, 0, 0, 0.65)
    cooldown:SetScript("OnShow", self.OnShow)
    cooldown:SetScript("OnHide", self.OnHide)
    cooldown.parent = parent

    return cooldown
end

function IconFactory:CreateBorder(parent, frameConfig)
    local borderWidth = frameConfig.border.edgeSize
    local border = parent:CreateTexture(nil, frameConfig.border.layer or "BORDER")
    border:SetPoint("TOPLEFT", -borderWidth, borderWidth)
    border:SetPoint("BOTTOMRIGHT", borderWidth, -borderWidth)
    border:SetTexture(frameConfig.border.edgeFile)

    return border
end

function IconFactory:CreateIndicators(parent)
    local indicatorBorder = parent.cooldown:CreateTexture(nil, "OVERLAY")
    indicatorBorder:SetTexture("Interface\\TalentFrame\\TalentFrame-RankBorder")
    indicatorBorder:SetSize(26, 26)
    indicatorBorder:SetPoint("CENTER", parent, "BOTTOMRIGHT", 0, 0)

    local indicatorText = parent.cooldown:CreateFontString(nil, "OVERLAY")
    indicatorText:SetFont(STANDARD_TEXT_FONT, 9)
    indicatorText:SetPoint("CENTER", indicatorBorder, 0, 0)

    return indicatorBorder, indicatorText
end

function IconFactory:CreateCategoryLabel(parent)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetFont(CATEGORY_FONT.font or label:GetFont(), CATEGORY_FONT.size, CATEGORY_FONT.flags)
    label:SetPoint("TOP", CATEGORY_FONT.x, CATEGORY_FONT.y)

    return label
end

function IconFactory:SetupMasqueForIcon(frame)
    if Diminish.MasqueGroup then
        Diminish.MasqueGroup:AddButton(frame, {
            Icon = frame.icon,
            Cooldown = frame.cooldown,
            Normal = frame:GetNormalTexture(),
            Border = frame.border,
        })
    end
end

function IconFactory:OnShow(frame)
    if frame.__OnCooldownStart then
        frame.__OnCooldownStart(frame)
    end
end

function IconFactory:OnHide(frame)
    if frame.__OnCooldownFinish then
        frame.__OnCooldownFinish(frame)
    end
end

function IconFactory:SetIndicatorColors()

end

function IconFactory:SetSpellTexture()

end
