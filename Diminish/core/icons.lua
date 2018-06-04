local _, NS = ...
local Icons = {}
NS.Icons = Icons

local anchorCache = {}
local frames = {}

local _G = _G
local GetTime = _G.GetTime
local CreateFrame = _G.CreateFrame
local gsub = _G.string.gsub
local strmatch = _G.string.match

function Icons:GetAnchor(unitID, defaultAnchor)
    if anchorCache[unitID] and not defaultAnchor then
        return anchorCache[unitID]
    end

    local unit, count = gsub(unitID, "%d", "") -- party1 -> party
    local anchors = NS.anchors[unit]
    if not anchors then return end

    for i = 1, #anchors do
        local name = anchors[i]

        if count > 0 then
            name = name .. strmatch(unitID, "%d+") -- add unit index to frame name
        end

        local frame = _G[name]

        if frame then
            if unit ~= "party" and unit ~= "arena" then
                -- cleanup target/focus/player table since these only need to be ran once
                NS.anchors[unit] = nil
            end

            if unit ~= "party" then -- AnchorPartyFrames() will handle party frames cache instead
                anchorCache[unitID] = frame
            end

            return frame
        end
    end
end

do
    local UnitGUID = _G.UnitGUID

    local function FindCompactRaidFrameByUnit(unitID)
        local guid = UnitGUID(unitID)
        if not guid then return end

        for i = 1, (#CompactRaidFrameContainer.flowFrames or 5) do
            --local frame = Icons:GetAnchor("raid"..i, true)
            local frame = _G["CompactRaidFrame"..i]
            if not frame then return end

            if frame.unit and UnitGUID(frame.unit) == guid then
                return frame
            end
        end
    end

    function Icons:AnchorPartyFrames(members)
        if not NS.db.unitFrames.party.enabled then return end

        for i = (NS.useCompactPartyFrames and 0 or 1), (members or 4) do
            local unit = i == 0 and "player" or "party"..i
            local parent

            if NS.useCompactPartyFrames then
                parent = FindCompactRaidFrameByUnit(unit)
            else
                parent = Icons:GetAnchor(unit, true)
            end

            if parent then
                if unit == "player" then
                    unit = "player-party"
                end

                anchorCache[unit] = parent
            end
        end
    end
end

do
    local pairs = _G.pairs

    local function MasqueAddFrame(frame)
        if not NS.MasqueGroup then return end

        frame:SetNormalTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")

        NS.MasqueGroup:AddButton(frame, {
            Icon = frame.icon,
            Cooldown = frame.cooldown,
            Normal = frame:GetNormalTexture(),
            Border = frame.border,
        })
    end

    local function UpdatePositions(cooldownFrame)
        local anchor = cooldownFrame.parent
        local unitFrame = anchor:GetParent()
        local unit = anchor.unit

        local cfg = anchor.unitSettingsRef
        local ofsX = not cfg.growLeft and (cfg.iconSize + cfg.iconPadding) or (-cfg.iconSize - cfg.iconPadding)
        local first = true

        for _, frame in pairs(frames[unit]) do
            if frame.shown then
                if first then
                    frame:SetPoint("CENTER", unitFrame, cfg.offsetX, cfg.offsetY)

                    first = false
                else
                    frame:SetPoint("CENTER", anchor, ofsX, 0)
                end

                anchor = frame
            end
        end
    end

    local function CooldownOnShow(self)
        local frame = self.parent
        local timer = frame.timerRef

        if timer and GetTime() >= (timer.expiration or 0) then
            NS.Timers:Remove(timer.unitGUID, timer.category)
            frame.timerRef = nil
        end

        if not frame:IsVisible() then
            -- Seems like there's a race condition that sometimes causes icons to not be shown
            -- Dunno exactly why so this fix will have to do for now.
            frame.shown = true
            frame:Show()
        end

        UpdatePositions(self)
    end

    local function CooldownOnHide(self)
        if self:GetCooldownDuration() <= 0 then
            local frame = self.parent
            local timer = frame.timerRef

            if timer then
                NS.Timers:Remove(timer.unitGUID, timer.category)
                frame.timerRef = nil
            end

            if frame:IsVisible() then
                frame.shown = false
                frame:Hide()
            end

            UpdatePositions(self)
        end
    end

    local function CreateIcon(unitID, category)
        local anchor = Icons:GetAnchor(unitID)
        if not anchor then return end

        local origUnitID
        if unitID == "player-party" then
            unitID = "party" -- use for party db settings
            origUnitID = "player-party"
        end

        -- Note to self: Do not inherit from any actionbutton template here or taint will occur
        local frame = CreateFrame("CheckButton", nil, anchor) -- CheckButton to support Masque
        frame.unit = origUnitID or unitID
        frame.unitFormatted = gsub(unitID, "%d", "")
        frame.unitSettingsRef = NS.db.unitFrames[frame.unitFormatted]

        local size = frame.unitSettingsRef.iconSize
        frame:SetSize(size, size)

        frame:SetFrameLevel(2)
        frame:SetFrameStrata("HIGH")
        frame:Disable()
        frame:EnableMouse(false)
        frame:Hide()

        frame.icon = frame:CreateTexture(nil, "BACKGROUND")
        frame.icon:SetAllPoints(frame)

        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints(frame)
        cooldown:SetHideCountdownNumbers(not NS.db.timerText)
        cooldown:SetDrawSwipe(NS.db.timerSwipe)
        cooldown:SetDrawEdge(false)
        cooldown:SetSwipeColor(0, 0, 0, 0.6)
        cooldown:SetScript("OnShow", CooldownOnShow)
        cooldown:SetScript("OnHide", CooldownOnHide)
        cooldown.parent = frame -- avoids calling :GetParent() later on
        frame.cooldown = cooldown

        frame.countdown = cooldown:GetRegions()
        frame.countdown:SetFont(frame.countdown:GetFont(), NS.db.timerTextSize)

        local border = frame:CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:SetTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
        frame.border = border

        -- label above an icon that displays category text
        local ctext = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
        ctext:SetFont(STANDARD_TEXT_FONT, 8)
        ctext:SetPoint("TOP", 0, 10)
        ctext:SetShown(NS.db.showCategoryText)
        if strlen(category) >= 10 then
            ctext:SetText(strsub(category, 1, 5)) -- truncate
        else
            ctext:SetText(category)
        end
        frame.categoryText = ctext

        MasqueAddFrame(frame)

        return frame
    end

    function Icons:GetFrame(unitID, category)
        if not unitID or not category then return end

        if frames[unitID] and frames[unitID][category] then
            return frames[unitID][category]
        end

        if not frames[unitID] then
            frames[unitID] = {}
        end

        local frame = CreateIcon(unitID, category)
        frames[unitID][category] = frame

        return frame
    end

    function Icons:OnFrameConfigChanged()
        for _, tbl in pairs(frames) do
            for _, frame in pairs(tbl) do
                frame.unitSettingsRef = NS.db.unitFrames[frame.unitFormatted] -- need to update pointer if changed profile
                frame.cooldown:SetHideCountdownNumbers(not NS.db.timerText)
                frame.cooldown:SetDrawSwipe(NS.db.timerSwipe)
                frame.countdown:SetFont(frame.countdown:GetFont(), NS.db.timerTextSize)
                frame.categoryText:SetShown(NS.db.showCategoryText)
                local size = frame.unitSettingsRef.iconSize
                frame:SetSize(size, size)

                UpdatePositions(frame.cooldown)

                frame.cooldown.noCooldownCount = NS.db.timerColors or not NS.db.timerText -- toggle OmniCC
                if NS.db.timerText and not NS.db.timerColors then
                    frame.countdown:SetTextColor(1, 1, 1, 1)
                end

                if NS.db.colorBlind then
                    frame.countdown:SetPoint("CENTER", 0, 3)
                    frame.border:SetVertexColor(0, 0, 0, 0)
                else
                    frame.countdown:SetPoint("CENTER", 0, 0)
                end

                if frame.indicator then
                    frame.indicator:SetShown(NS.db.colorBlind)
                end
            end
        end

        if self.MSQGroup then
            self.MSQGroup:ReSkin()
        end
    end
end

function Icons:HideAll()
    for unitID, tbl in pairs(frames) do
        for category, frame in pairs(tbl) do
            frame.shown = false
            frame:Hide()
        end
    end
end

do
    local textureCachePlayer = {}
    local indicatorColors = NS.DR_STATES_COLORS
    local GetSpellTexture = _G.GetSpellTexture

    local indicatorTexts = { "50%", "75%", "100%" }

    local function SetIndicators(frame, applied)
        if NS.db.colorBlind then
            if not frame.indicator then
                frame.indicator = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
                frame.indicator:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
                frame.indicator:SetPoint("BOTTOMRIGHT", 0, 0)
                frame.countdown:SetPoint("CENTER", 0, 3)
            end

            frame.indicator:SetText(indicatorTexts[applied])
            return
        end

        local color = indicatorColors[applied]
        if not color then return end

        if Icons.MSQGroup then
            frame.__MSQ_NormalTexture:SetVertexColor(color[1], color[2], color[3], 1)
            frame.border:SetVertexColor(frame.border.__MSQ_Color)
        else
            frame.border:SetVertexColor(color[1], color[2], color[3], 1)
        end

        if NS.db.timerText and NS.db.timerColors then
            frame.countdown:SetTextColor(color[1], color[2], color[3], 1)
        end
    end

    local function SetSpellTexture(frame, timer)
        if NS.db.spellBookTextures then
            if not textureCachePlayer[timer.category] and timer.srcGUID == UnitGUID("player") then
                textureCachePlayer[timer.category] = GetSpellTexture(timer.spellID)
            end
        end

        -- always set texture that player has cast before for this category, but only if timer is for enemy target
        if NS.db.spellBookTextures and textureCachePlayer[timer.category] and not timer.isFriendly then
            frame.icon:SetTexture(textureCachePlayer[timer.category])
        else
            frame.icon:SetTexture(GetSpellTexture(timer.spellID))
        end
    end

    function Icons:StartCooldown(timer, unitID)
        local frame = self:GetFrame(unitID, timer.category)
        if not frame then return end

        local now = GetTime()
        local expiration = timer.expiration - now
        frame.timerRef = timer

        SetSpellTexture(frame, timer)
        SetIndicators(frame, timer.applied)

        if frame.shown then
            --if ((frame.cooldown:GetCooldownDuration() / 1000) - expiration) > 1.1 then
                if not timer.testMode then
                    frame.cooldown:SetCooldownDuration(expiration)
                end
            --end
        else
            frame.shown = true
            frame.cooldown:SetCooldown(now, expiration)
            frame:Show()
        end
    end

    function Icons:StopCooldown(timer, unitID, isFinished)
        local frame = Icons:GetFrame(unitID, timer.category)
        if not frame then return end

        if isFinished and frame.timerRef then
            frame.timerRef.applied = 0
            frame.timerRef = nil
        end

        frame.shown = false
        frame:Hide()
    end
end
