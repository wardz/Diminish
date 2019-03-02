local AnchorManager = {}
local cache = {}

function AnchorManager:GetAnchor(unitID, getDefaults)
    if cache[unitID] and not getDefaults then
        return cache[unitID]
    end

    local unitType, count = gsub(unitID, "%d", "") -- party1 -> party

    if unitType == "nameplate" then
        return self:GetNamePlateForUnit(unitID, getDefaults)
    end

    local frame = self:GetUnitFrameForUnit(unitType, unitID, count > 0)
    if frame and not getDefaults then
        cache[unitID] = frame
    end

    return frame
end

function AnchorManager:GetNameplateForUnit(unitID)
    if unitID == "nameplate-test" then
        unitID = "target"
    end

    local plate = C_NamePlate.GetNamePlateForUnit(unitID)
    if not plate then return end

    if plate.UnitFrame and plate.unitFrame then -- special case for ElvUI
        return plate.unitFrame.HealthBar
    end

    return plate
end

function AnchorManager:GetUnitFrameForUnit(unitType, unitID, hasNumberIndex)
    local anchorNames = NS.anchors[unitType]
    if not anchorNames then return end

    for i = 1, #anchorNames do
        local name = anchorNames[i]
        if hasNumberIndex then
            name = format(name, strmatch(unitID, "%d+")) -- add unit index to unitframe name
        end

        local frame = _G[name]
        if frame then return frame end
    end
end

function AnchorManager:GetGroupFrameByUnit(unitID, isRaid)
    local guid = UnitGUID(unitID)
    if not guid then return end

    local unitType = isRaid and "raid" or "party"
    for i = 1, 40 do -- frames are recycled so scan through all available
        local frame = self:GetAnchor(unitType..i, true)
        if not frame then return end -- no more frames available

        if frame and frame.unit and UnitGUID(frame.unit) == guid then
            return frame
        end
    end
end

function AnchorManager:ParentToGroupFrames(frames, groupSize)
    local usesCompact = GetCVarBool("useCompactPartyFrames")

    for i = 0, (groupSize or 4) do
        local unitID = i == 0 and "player" or "party"..i
        local parent = self:GetGroupFrameByUnit(unitID, usesCompact)

        if parent then
            if unitID == "player" then
                unitID = "player-party"
            end

            cache[unitID] = parent

            if frames[unitID] then
                for category, frame in pairs(frames[unitID]) do
                    frame:ClearAllPoints()
                    frame:SetParent(parent)
                end
            end
        end
    end
end
