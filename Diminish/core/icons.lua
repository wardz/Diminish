local _, NS = ...
local Icons = {}
local frames = {}
NS.Icons = Icons
NS.iconFrames = frames

local _G = _G
local UnitGUID = _G.UnitGUID
local GetTime = _G.GetTime
local gsub = _G.string.gsub
local format = _G.string.format
local strmatch = _G.string.match
local math_max = _G.math.max
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT

local anchorCache = {}

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
            name = format(name, strmatch(unitID, "%d+")) -- add unit index to frame name
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
    local function FindCompactRaidFrameByUnit(unitID)
        local guid = UnitGUID(unitID)
        if not guid then return end

        for i = 1, (#CompactRaidFrameContainer.flowFrames or 5) do
            --local frame = Icons:GetAnchor("raid"..i, true)
            local frame = _G["CompactRaidFrame"..i]
            if not frame then return end -- no more frames

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

                if frames[unit] then
                    -- Anchor existing DR icons to new parent
                    for category, frame in pairs(frames[unit]) do
                        frame:ClearAllPoints()
                        frame:SetParent(parent)
                    end
                end
            end
        end
    end
end

do
    local CreateFrame = _G.CreateFrame
    local strfind = _G.string.find
    local strlen = _G.string.len
    local pairs = _G.pairs

    local function MasqueAddFrame(frame)
        if not NS.MasqueGroup then return end

        frame:SetNormalTexture(NS.db.borderTexture)

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
            return NS.Timers:Remove(timer.unitGUID, timer.category)
        end

        -- Seems to be an extremely rare occassion that the frame itself is not shown
        -- but the cooldown frame is. No idea why, so always force show here
        if not frame:IsVisible() then
            frame.shown = true
            frame:Show()
        end

        UpdatePositions(self)
    end

    local function CooldownOnHide(self)
        local frame = self.parent
        local timer = frame.timerRef

        if timer and self:GetCooldownDuration() <= 0.3 then
            NS.Timers:Remove(timer.unitGUID, timer.category)
        end

        if frame:IsVisible() then
            frame.shown = false
            frame:Hide()
        end

        UpdatePositions(self)
    end

    local function CreateIcon(unitID, category)
        local anchor = Icons:GetAnchor(unitID)
        if not anchor then return end

        local origUnitID
        if unitID == "player-party" then
            unitID = "party" -- use for party db settings
            origUnitID = "player-party"
        end

        local db = NS.db

        -- Note to self: Do not inherit from any actionbutton template here or taint will occur
        local frame = CreateFrame("CheckButton", nil, anchor) -- CheckButton to support Masque
        frame.unit = origUnitID or unitID
        frame.unitFormatted = gsub(unitID, "%d", "")
        frame.unitSettingsRef = db.unitFrames[frame.unitFormatted]

        local size = frame.unitSettingsRef.iconSize
        frame:SetSize(size, size)
        frame:SetFrameStrata("HIGH")
        frame:EnableMouse(false)
        frame:Hide()

        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetAllPoints(frame)
        frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints(frame)
        cooldown:SetHideCountdownNumbers(not db.timerText)
        cooldown:SetDrawSwipe(db.timerSwipe)
        cooldown:SetDrawEdge(false)
        cooldown:SetSwipeColor(0, 0, 0, 0.65)
        cooldown:SetScript("OnShow", CooldownOnShow)
        cooldown:SetScript("OnHide", CooldownOnHide)
        cooldown.parent = frame -- avoids calling :GetParent() later on
        frame.cooldown = cooldown

        frame.countdown = cooldown:GetRegions()
        frame.countdown:SetFont(frame.countdown:GetFont(), db.timerTextSize)

        local borderWidth = db.border.edgeSize
        local border = frame:CreateTexture(nil, db.border.layer or "BORDER")
        border:SetPoint("TOPLEFT", -borderWidth, borderWidth)
        border:SetPoint("BOTTOMRIGHT", borderWidth, -borderWidth)
        border:SetTexture(db.border.edgeFile)
        frame.border = border

        -- label above an icon that displays category text
        local ctext = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ctext:SetFont(ctext:GetFont(), 9)
        ctext:SetPoint("TOP", 0, 12)
        ctext:SetShown(db.showCategoryText)
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

    -- Refresh everything for icons. Called by Diminish_Options.
    -- Function is deleted if options is not loaded.
    function Icons:OnFrameConfigChanged()
        local db = NS.db
        for _, tbl in pairs(frames) do
            for _, frame in pairs(tbl) do
                frame.unitSettingsRef = db.unitFrames[frame.unitFormatted] -- need to update pointer if changed profile
                frame.cooldown:SetHideCountdownNumbers(not db.timerText)
                frame.cooldown:SetDrawSwipe(db.timerSwipe)
                frame.countdown:SetFont(frame.countdown:GetFont(), db.timerTextSize)
                frame.categoryText:SetShown(db.showCategoryText)
                local size = frame.unitSettingsRef.iconSize
                frame:SetSize(size, size)

                if not NS.MasqueGroup then
                    frame.border:SetDrawLayer(db.border.layer or "BORDER")
                    frame.border:SetTexture(db.border.edgeFile)
                    frame.border:SetPoint("TOPLEFT", -db.border.edgeSize, db.border.edgeSize)
                    frame.border:SetPoint("BOTTOMRIGHT", db.border.edgeSize, -db.border.edgeSize)
                end

                frame.cooldown.noCooldownCount = db.timerColors or not db.timerText -- toggle OmniCC
                if db.timerText and not db.timerColors then
                    frame.countdown:SetTextColor(1, 1, 1, 1)
                end

                if db.colorBlind then
                    frame.countdown:SetPoint("CENTER", 0, 5)
                    frame.border:SetVertexColor(0.4, 0.4, 0.4, 0.8)
                    if frame.indicator then
                        frame.indicator:SetFont(STANDARD_TEXT_FONT, math_max(11, frame.unitSettingsRef.iconSize / 3), "OUTLINE")
                        frame.indicator:ClearAllPoints()
                        frame.indicator:SetPoint(db.timerText and "BOTTOMRIGHT" or "CENTER", frame.cooldown, 0, 0)
                    end
                else
                    frame.countdown:SetPoint("CENTER", 0, 0)
                end

                if frame.indicator then
                    frame.indicator:SetShown(db.colorBlind)
                end

                UpdatePositions(frame.cooldown)
            end
        end

        if NS.MasqueGroup then
            NS.MasqueGroup:ReSkin()
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
    local GetSpellTexture = _G.GetSpellTexture
    local CATEGORY_TAUNT = NS.CATEGORIES.TAUNT
    local indicatorColors = NS.DR_STATES_COLORS
    local indicatorTexts = NS.DR_STATES_TEXT
    local DR_TIME = NS.DR_TIME

    local function SetIndicators(frame, applied, category)
        local color
        if category ~= CATEGORY_TAUNT then
            color = indicatorColors[applied]
            if not color then return end
        else
            -- Taunts aren't immune until fifth applied
            color = applied <= 4 and indicatorColors[1] or indicatorColors[3]
        end

        if not NS.db.colorBlind then
            if Icons.MSQGroup then
                frame.__MSQ_NormalTexture:SetVertexColor(color[1], color[2], color[3], 1)
                frame.border:SetVertexColor(frame.border.__MSQ_Color)
            else
                frame.border:SetVertexColor(color[1], color[2], color[3], 1)
            end

            if NS.db.timerText and NS.db.timerColors then
                frame.countdown:SetTextColor(color[1], color[2], color[3], 1)
            end
        else -- Show indicators using text only
            if not frame.indicator then
                frame.indicator = frame.cooldown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                frame.indicator:SetFont(STANDARD_TEXT_FONT, math_max(11, frame.unitSettingsRef.iconSize / 3), "OUTLINE")
                frame.indicator:SetPoint(NS.db.timerText and "BOTTOMRIGHT" or "CENTER", 0, 0)
                frame.countdown:SetPoint("CENTER", 0, 5)
                frame.border:SetVertexColor(0.4, 0.4, 0.4, 0.8)
            end

            if category ~= CATEGORY_TAUNT then
                frame.indicator:SetTextColor(color[1], color[2], color[3], 1)
                frame.indicator:SetText(indicatorTexts[applied])
            else
                frame.indicator:SetTextColor(color[1], color[2], color[3], 1)
                frame.indicator:SetText(applied <= 4 and applied or indicatorTexts[3])
            end
        end
    end

    local function SetSpellTexture(frame, timer)
        if NS.db.spellBookTextures then
            if not textureCachePlayer[timer.category] then
                if timer.srcGUID == NS.Diminish.PLAYER_GUID or timer.srcGUID == UnitGUID("pet") then
                    textureCachePlayer[timer.category] = GetSpellTexture(timer.spellID)
                end
            end
        end

        -- always set texture that player has cast before for this category, but only if timer is for enemy target
        if NS.db.spellBookTextures and textureCachePlayer[timer.category] and not timer.isFriendly then
            frame.icon:SetTexture(textureCachePlayer[timer.category])
        else
            frame.icon:SetTexture(GetSpellTexture(timer.spellID))
        end
    end

    function Icons:StartCooldown(timer, unitID, onAuraEnd)
        local frame = self:GetFrame(unitID, timer.category)
        if not frame then return end

        local now = GetTime()
        local expiration = timer.expiration - now
        frame.timerRef = timer

        SetSpellTexture(frame, timer)
        SetIndicators(frame, timer.applied, timer.category)

        if frame.shown then
            if timer.testMode then return end

            if not onAuraEnd or NS.db.timerStartAuraEnd then
                -- frame.cooldown:SetCooldownDuration(expiration) -- doesn't work with omnicc :(
                frame.cooldown:SetCooldown(now, expiration)
            else
                -- Refresh cooldown without resetting timer swipe (on aura broke/end for mode timerStartAuraEnd=false)
                -- Thanks to sArena for this
                local startTime, startDuration = frame.cooldown:GetCooldownTimes()
                startTime, startDuration = startTime/1000, startDuration/1000

                local newDuration = DR_TIME / (1 - ((now - startTime) / startDuration))
                local newStartTime = DR_TIME + now - newDuration
                frame.cooldown:SetCooldown(newStartTime, newDuration)
            end
        else
            frame.shown = true
            frame.cooldown:SetCooldown(now, expiration)
            frame:Show()
        end
    end

    function Icons:StopCooldown(timer, unitID, isFinished)
        local frame = frames[unitID] and frames[unitID][timer.category]
        if not frame then return end

        if isFinished and frame.timerRef then
            frame.timerRef = nil
        end

        frame.shown = false
        frame:Hide()
    end
end
