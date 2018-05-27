local _, NS = ...
local L = NS.L

local isTesting = false
local isAnchoring = false

local backdrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = false,
}

local TestMode = {}
TestMode.pool = CreateFramePool("Frame") -- just for testing
NS.TestMode = TestMode

-- Thanks sArena
local function CalcPoint(frame)
    local parentX, parentY = frame:GetParent():GetCenter()
    local frameX, frameY = frame:GetCenter()

    parentX, parentY, frameX, frameY = parentX + 0.5, parentY + 0.5, frameX + 0.5, frameY + 0.5

    if not frameX then return end

    local scale = frame:GetScale()

    parentX, parentY = floor(parentX), floor(parentY)
    frameX, frameY = floor(frameX * scale), floor(frameY * scale)
    frameX, frameY = floor((parentX - frameX) * -1), floor((parentY - frameY) * -1)

    return frameX/scale, frameY/scale
end

local function OnDragStop(self)
    self:StopMovingOrSizing()

    -- Create new profile after moving frames if we're still on Default profile
    NS.CreateNewProfile()

    -- frames loses relativity to parent and is instead relative to UIParent after dragging
    -- so we cant just use self:GetPoint()
    local xOfs, yOfs = CalcPoint(self)

    local db = DIMINISH_NS.db.unitFrames[self.realUnit]
    --db.point = "CENTER"
    db.offsetY = yOfs
    db.offsetX = xOfs

    local isArena = strfind(self.unit, "arena")
    local isParty = strfind(self.unit, "party") or strfind(self.unit, "player-party")

    -- Update position for all party/arena frames after draggin 1 of them
    if isArena or isParty then
        for frame in TestMode.pool:EnumerateActive() do
            if isArena and strfind(frame.unit, "arena") or isParty and strfind(frame.unit, "party") then
                frame:ClearAllPoints()
                frame:SetPoint("CENTER", frame:GetParent(), db.offsetX, db.offsetY)
            end
        end
    end
end

local function OnEnter(self)
    SetCursor("Interface\\CURSOR\\UI-Cursor-Move")
end

local function OnLeave(self)
    ResetCursor()
end

function TestMode:IsTestingOrAnchoring()
    return isTesting or isAnchoring
end

local function PartyOnHide(self)
    -- If you hit Escape or Cancel in InterfaceOptions instead of "Okay" button then for some reason
    -- blizzard auto hides the PartyMember frames so hook them and prevent hiding when testing
    if not InCombatLockdown() and isTesting or isAnchoring then
        self:Show()
    end
end

function TestMode:ToggleArenaAndPartyFrames(state)
    if isTesting or isAnchoring then return end

    local settings = DIMINISH_NS.db.unitFrames

    if settings.arena.enabled and not IsAddOnLoaded("Blizzard_ArenaUI") then
        LoadAddOn("Blizzard_ArenaUI")
    end

    local showFlag
    if state ~= nil then
        showFlag = state
    else
        showFlag = not ArenaEnemyFrames:IsShown()
    end

    local isInArena = select(2, IsInInstance()) == "arena"

    if settings.arena.enabled and not isInArena then
        ArenaEnemyFrames:SetShown(showFlag)
        if LibStub and LibStub("AceAddon-3.0", true) then
            local _, sArena = pcall(function() return LibStub("AceAddon-3.0"):GetAddon("sArena") end)
            if sArena and sArena.ArenaEnemyFrames then
                -- sArena anchors frames to sArena.ArenaEnemyFrames instead of _G.ArenaEnemyFrames
                sArena.ArenaEnemyFrames:SetShown(showFlag)
            end
        end
    end

    local useCompact = GetCVarBool("useCompactPartyFrames")
    if useCompact and settings.party.enabled and showFlag then
        if not IsInGroup() then
            print("Diminish: " .. L.COMPACTFRAMES_ERROR)
        end
    end

    for i = 1, 3 do
        if not isInArena then
            if _G["ArenaEnemyFrame"..i] and _G["ArenaEnemyFrame"..i]:IsVisible() or settings.arena.enabled then
                _G["ArenaEnemyFrame"..i]:SetShown(showFlag)
            end
        end

        if not useCompact and not IsInGroup() then -- _G["PartyMemberFrame"..i]:IsVisible()
            if settings.party.enabled then
                if not UnitExists(_G["PartyMemberFrame"..i]) then -- do not toggle if frame belongs to a group member
                    _G["PartyMemberFrame"..i]:SetShown(showFlag)
                    _G["PartyMemberFrame"..i]:HookScript("OnHide", PartyOnHide)
                end
            end
        end
    end
end

function TestMode:HideAnchors()
    for frame in self.pool:EnumerateActive() do
        frame:Hide()
        self.pool:Release(frame)
    end
    isAnchoring = false
    TestMode:ToggleArenaAndPartyFrames(false)
end

function TestMode:CreateDummyAnchor(parent, unit)
    if not parent then return end

    local db = DIMINISH_NS.db.unitFrames[unit]
    if not db or not db.enabled then return end

    local isCompact = strfind(parent:GetName() or "", "Compact")
    if isCompact and not parent:IsShown() then return end

    local frame, isNew = self.pool:Acquire()
    frame:SetParent(parent)
    frame.realUnit = unit

    local unit = parent.unit
    if parent.unit == "player" and isCompact then
        unit = "player-party"
    end

    frame.unit = unit

    if isNew then
        frame.tooltip = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        frame.tooltip:SetPoint("TOP", frame, 0, 10)

        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton", "RightButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", OnDragStop)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:SetFrameLevel(1)
        frame:SetBackdrop(backdrop)
        frame:SetBackdropColor(1, 0, 0, 1)
        frame:SetFrameLevel(1)
        frame:SetFrameStrata("HIGH")

        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)
    end

    frame.tooltip:SetFormattedText(L.ANCHORDRAG, strupper(unit), db.growLeft and L.LEFT or L.RIGHT)
    frame:SetSize(db.iconSize, db.iconSize)
    frame:SetPoint("CENTER", parent, db.offsetX, db.offsetY)
    frame:Show()

    isAnchoring = true
end

function TestMode:ShowAnchors()
    TestMode:ToggleArenaAndPartyFrames(true)

    for _, unitID in pairs(NS.unitFrames) do
        if unitID == "arena" then
            for i = 1, 3 do
                local anchor = DIMINISH_NS.Icons:GetAnchor(unitID..i)
                TestMode:CreateDummyAnchor(anchor, unitID)
            end
        elseif unitID == "party" then
            for i = 1, 3 do
                local compact = _G["CompactRaidFrame"..i]
                --local compact = DIMINISH_NS.Icons:FindCompactUnitFrameByID(unitID..i)
                local anchor = compact and compact:IsVisible() and compact or DIMINISH_NS.Icons:GetAnchor(unitID..i)
                TestMode:CreateDummyAnchor(anchor, unitID)
            end
        else
            local anchor = DIMINISH_NS.Icons:GetAnchor(unitID)
            TestMode:CreateDummyAnchor(anchor, unitID)
        end
    end
end

function TestMode:Test(hide)
    if InCombatLockdown() then
        return print(L.COMBATLOCKDOWN_ERROR)
    end

    if isTesting or hide then
        isTesting = false
        TestMode:ToggleArenaAndPartyFrames(false)
        DIMINISH_NS.Timers:ResetAll(true)
        return
    end

    TestMode:ToggleArenaAndPartyFrames(true)
    isTesting = true

    local DNS = DIMINISH_NS
    DNS.Timers:Insert(UnitGUID("player"), nil, DNS.CATEGORIES.STUN, 81429, false, true, true)
    DNS.Timers:Insert(UnitGUID("player"), nil, DNS.CATEGORIES.ROOT, 122, false, true, true)
    DNS.Timers:Insert(UnitGUID("player"), nil, DNS.CATEGORIES.INCAPACITATE, 118, false, true, true)
end
