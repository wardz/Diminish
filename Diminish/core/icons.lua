local _, NS = ...
local Icons = {}
local partyFrames = {}
local frames = {}
NS.Icons = Icons

local _G = _G
local GetTime = _G.GetTime
local GetSpellTexture = _G.GetSpellTexture
local CreateFrame = _G.CreateFrame
local gsub = _G.string.gsub

do
    local strmatch = _G.string.match
    local anchorCache = {}

    function Icons:GetAnchor(unitID, partyDefaultAnchor)
        local unit, count = gsub(unitID, "%d", "") -- party1 -> party

        if unit == "party" and not partyDefaultAnchor then
            -- special case, we have custom main anchors for party frames too avoid taint
            return partyFrames[unitID]
        end

        if unit == "player-party" then -- CompactRaidFrame for player
            return partyFrames.player
        end

        if anchorCache[unitID] then
            return anchorCache[unitID]
        end

        -- Loop through all possible unitframe anchors, return & cache permanently first one that exists for this unitID
        -- basically just a lazy way to add third party addon frame support.
        -- note to self: blizzard frames must always be ran last here
        local anchors = NS.anchors[unit]
        for i = 1, #anchors do
            local name = anchors[i]

            if count > 0 then
                name = name .. strmatch(unitID, "%d+") -- add unit index to frame name
                -- name = format(name, strmatch(unitID, "%d+"))
            end

            local frame = _G[name]
            if frame then
                anchorCache[unitID] = frame
                if unit ~= "party" and unit ~= "arena" then
                    -- cleanup target/focus/player since these only need to be ran once
                    NS.anchors[unit] = nil
                end
                return frame
            end
        end
    end
end

do
    local UnitGUID = _G.UnitGUID

    local function FindCompactRaidFrameByUnit(unit)
        local guid = UnitGUID(unit)
        if not guid then return end

        for i = 1, (#CompactRaidFrameContainer.flowFrames or 5) do
            --local frame = Icons:GetAnchor("raid"..i, true)
            local frame = _G["CompactRaidFrame"..i]
            if not frame then return end

            if frame and frame.unit and UnitGUID(frame.unit) == guid then
                return frame
            end
        end
    end

    local function SetupPartyAnchors(unit, anchor, iconSize)
        if not partyFrames[unit] then
            -- Create a dummy frame we can anchor all trackers to for every party member
            -- (we can't use f:SetParent() _directly_ on CompactRaidFrame while in combat)
            partyFrames[unit] = CreateFrame("Frame", nil, anchor)
            partyFrames[unit].unit = unit
            partyFrames[unit].isPartyFrameAnchor = true
            partyFrames[unit]:SetPoint("CENTER", 0, 0)
            partyFrames[unit]:SetSize(iconSize * NS.MAX_CATEGORIES, iconSize)
            partyFrames[unit]:EnableMouse(false)
        else
            -- CompactRaidFrameXX can be any unitID unlike PartyMemberFrames where frame1 is always party1
            -- so reanchor everytime here to whatever raid/party frame unitX is at
            -- partyFrames[unit].unit = unit
            partyFrames[unit]:SetParent(anchor)
        end
    end

    function Icons:AnchorRaidFrames(members)
        if not NS.db or not NS.db.unitFrames.party.enabled then return end
        if not NS.useCompactPartyFrames then return end

        if InCombatLockdown() or UnitAffectingCombat("player") then
            -- Try again every 3s until player has left combat
            return C_Timer.After(3, Icons.AnchorRaidFrames)
        end

        local cfg = NS.db.unitFrames
        local iconSize = cfg.party.iconSize

        for i = 0, (members or 4) do
            local unit = i == 0 and "player" or "party"..i
            local anchor = FindCompactRaidFrameByUnit(unit)

            if anchor then
                SetupPartyAnchors(unit, anchor, iconSize)
            end
        end
    end

    function Icons:AnchorPartyFrames(members)
        if not NS.db or not NS.db.unitFrames.party.enabled then return end
        if NS.useCompactPartyFrames then return end

        if InCombatLockdown() or UnitAffectingCombat("player") then
            return C_Timer.After(3, Icons.AnchorPartyFrames)
        end

        local iconSize = NS.db.unitFrames.party.iconSize

        for i = 1, members or 4 do
            local anchor = Icons:GetAnchor("party"..i, true)
            if anchor then
                SetupPartyAnchors("party"..i, anchor, iconSize)
            end
        end
    end
end

do
    local pairs = _G.pairs

    local function AddMasque(frame)
        Icons.MSQ = Icons.MSQ or LibStub and LibStub("Masque", true)
        if not Icons.MSQ then return end

        Icons.MSQGroup = Icons.MSQGroup or Icons.MSQ:Group("Diminish")
        if not Icons.MSQGroup then return end

        frame:SetNormalTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
        -- FIXME: border:SetVertexColor doesnt work with some Masque skins because Masque hooks it and prevent changes
        -- might want to use backdrops instead

        Icons.MSQGroup:AddButton(frame, {
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

        --local cfg = NS.db.unitFrames[gsub(unit == "player-party" and "party" or unit, "%d", "")]
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
        local timer = self.parent.timerRef
        if timer and GetTime() >= (timer.expiration or 0) then
        -- if timer and self:GetCooldownDuration() <= 0 then
            NS.Timers:Remove(timer.unitGUID, timer.category)
        end

        if not self.parent:IsVisible() then
            -- Seems like there's a race condition that sometimes causes
            -- icons to not be shown when multiple unitframes have same timers.
            -- Dunno exactly why so this fix will have to do for now.
            self.parent:Show()
            self.parent.shown = true
        end

        UpdatePositions(self)
    end

    local function CooldownOnHide(self)
        if self:GetCooldownDuration() <= 0 then
            local timer = self.parent.timerRef
            if timer then
                NS.Timers:Remove(timer.unitGUID, timer.category)
            end

            if self.parent:IsVisible() then
                self.parent:Hide()
                self.parent.shown = false
            end

            UpdatePositions(self)
        end
    end

    local function CreateIcon(unitID, category)
        local anchor = Icons:GetAnchor(unitID)
        if not anchor then return end

        local origUnitID
        if unitID == "player-party" then
            unitID = "party" -- use for party settings
            origUnitID = "player-party"
        end

        -- Note to self: avoid inheriting from any action template here or taint will occur when frames are created in combat
        local frame = CreateFrame("CheckButton", nil, anchor) -- CheckButton to support Masque
        frame:SetFrameLevel(2)
        frame:SetFrameStrata("HIGH")
        frame:Disable()
        frame:EnableMouse(false)
        frame:Hide()
        frame.unit = origUnitID or unitID

        frame.unitSettingsRef = NS.db.unitFrames[gsub(unitID, "%d", "")]
        local size = frame.unitSettingsRef.iconSize
        frame:SetSize(size, size)

        frame.icon = frame:CreateTexture(nil, "BACKGROUND")
        frame.icon:SetAllPoints(frame)

        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints(frame)
        cooldown:SetHideCountdownNumbers(not NS.db.timerText)
        cooldown:SetDrawSwipe(NS.db.timerSwipe)
        cooldown:SetDrawEdge(false)
        cooldown:SetSwipeColor(0, 0, 0, 0.65)
        cooldown:SetScript("OnShow", CooldownOnShow)
        cooldown:SetScript("OnHide", CooldownOnHide)
        cooldown.parent = frame -- avoids calling :GetParent() later on
        frame.cooldown = cooldown

        local border = frame:CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:SetTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
        frame.border = border

        -- label above an icon that displays category text
        local ctext = frame:CreateFontString()
        ctext:SetFont(STANDARD_TEXT_FONT, 8)
        ctext:SetPoint("TOP", 0, 10)
        ctext:SetShown(NS.db.showCategoryText)
        if strlen(category) >= 10 then
            ctext:SetText(strsub(category, 1, 5)) -- truncate
        else
            ctext:SetText(category)
        end
        frame.categoryText = ctext

        frame.countdown = cooldown:GetRegions()
        frame.countdown:SetFont(frame.countdown:GetFont(), NS.db.timerTextSize)

        AddMasque(frame)

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
                frame.unitSettingsRef = NS.db.unitFrames[gsub(frame.unit == "player-party" and "party" or frame.unit, "%d", "")] -- need to update pointer if changed profile
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
            end
        end

        if self.MSQGroup then
            self.MSQGroup:ReSkin()
        end
    end
end

do
    local textureCachePlayer = {}
    local DR_STATES_COLORS = NS.DR_STATES_COLORS

    local function SetIndicators(frame)
        local color = DR_STATES_COLORS[frame.timerRef.applied]
        if not color then return end

        frame.border:SetVertexColor(color[1], color[2], color[3], color[4])

        if NS.db.timerText and NS.db.timerColors then
            frame.countdown:SetTextColor(color[1], color[2], color[3], color[4])
        end
    end

    function Icons:StartCooldown(timer, unitID)
        local frame = self:GetFrame(unitID, timer.category)
        if not frame then return end

        if NS.db.spellBookTextures then
            if not textureCachePlayer[timer.category] and timer.srcGUID == UnitGUID("player") then
                textureCachePlayer[timer.category] = GetSpellTexture(timer.spellID)
            end
        end

        if NS.db.spellBookTextures and textureCachePlayer[timer.category] and not timer.isFriendly then
            -- always set texture that player has cast before for this category, but only if timer is for enemy target
            frame.icon:SetTexture(textureCachePlayer[timer.category])
        else
            frame.icon:SetTexture(GetSpellTexture(timer.spellID))
        end

        frame.timerRef = timer
        SetIndicators(frame)

        local now = GetTime()
        local expiration = timer.expiration - now

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

function Icons:HideAll()
    for _, tbl in pairs(frames) do
        for _, frame in pairs(tbl) do
            frame.shown = false
            frame:Hide()
        end
    end
end
