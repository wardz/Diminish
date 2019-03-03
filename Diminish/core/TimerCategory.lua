local CategoryMixin = {}
local DR_DURATION_TIME = 18.5

function CategoryMixin:IncrementDR()
    if not self.isTestMode then
        self.diminishLevel = min(self.diminishLevel + 1, self.maxDiminishLevel)
    else
        self.diminishLevel = random(1, self.maxDiminishLevel)
    end

    return self -- allow method chaining
end

function CategoryMixin:IsExpired(timestamp)
    return self.expirationTime <= (timestamp or GetTime())
end

function CategoryMixin:Insert(destGUID, spellID, category, isFriendly, isNotPetOrPlayer, isTestMode)
    self.expirationTime = GetTime() + DR_DURATION_TIME
    self.category = category
    self.spellID = spellID
    self.destGUID = destGUID
    self.isNotPetOrPlayer = isNotPetOrPlayer
    self.isFriendly = isFriendly
    self.isTestMode = isTestMode

    self.maxDiminishLevel = category == CATEGORY_TAUNT and 5 or 3
    self.diminishLevel = 1

    local _, englishClass = GetPlayerInfoByGUID(dstGUID)
    self.unitClass = englishClass or "UNKNOWN"

    return self -- allow method chaining
end


-- Diminish.timers[guid][cat]:Start()
-- Diminish:Refresh("target")

--CategoryMixin = Module('CategoryData', config):Include(Icons, Debug ...)

-- factory:
-- local timer = NewCategoryData()
-- function NewCategoryData()
    -- return next(pool.CategoryMixin) or Mixin({}, CategoryMixin)
--end

function CategoryMixin:Delete()
    --wipe(self)
    Diminish.timers[self.dstGUID][self.category] = nil
end

function CategoryMixin:Update(spellID, isFriendly, isDiminished)
    self.spellID = spellID
    self.isFriendly = isFriendly -- update this incase player was mind controlled
    self.startTime = GetTime()

    if isDiminished then
        self:IncrementDR()
    end

    return self
end

local function ShouldShowRootOrTaunt(unitID)
    local classification = UnitClassification(unitID)
    if classification == "normal" or classification == "trivial" or classification == "minus" then
        if not UnitIsQuestBoss(unitID) then
            return false
        end
    end

    return true
end

function CategoryMixin:IsDisabled(unitID, unitType)
    local cfg = db.unitFrames[unitType]
    if not cfg or not cfg.enabled then return end
    if cfg.disabledCategories[self.category] then return end

    if not self.isTestMode then
        if not cfg.isEnabledForZone then return end
        if self.isFriendly and not cfg.watchFriendly then return end
    end

    if self.isNotPetOrPlayer and (self.category == CATEGORY_ROOT or self.category == CATEGORY_TAUNT) then
        if not ShouldShowRootOrTaunt(unitID) then return end-- TODO: del timer
    end

    return true
end

function CategoryMixin:CheckDiminishedAnomaly(duration)
    if self.diminishLevel >= 2 and duration >= 5 then
        self.diminishLevel = 1
    elseif self.diminishLevel > 3 and duration > 0 then
        if self.category ~= CATEGORY_TAUNT then
            self.diminishLevel = 1
        end
    end

    return self
end

local function GetDebuffTimes(unitID, spellID)
    for i = 1, 40 do
        local _, _, _, _, duration, expirationTime, _, _, _, id = UnitAura(unitID, i, "HARMFUL")
        if not spellID then return end -- no more debuffs available

        if spellID == id then
            return duration, expirationTime
        end
    end
end

function CategoryMixin:StartForUnit(unitID, unitType, isAuraApplied)
    if self:IsDisabled() then return end

    -- Add debuff duration to DR timer (18s + duration)
    -- when we're on SPELL_AURA_APPLIED event
    if isAuraApplied and not self.isTestMode then
        local duration, expirationTime = GetDebuffTimes(unitID, self.spellID)
        if expirationTime > 0 then
            self.expirationTime = expirationTime + DR_DURATION_TIME
            self:CheckDiminishedAnomaly(duration)
        end
    end

    self:TryStartCooldown()
end

function CategoryMixin:StopOrPause()
    self:TryStopCooldown()
end

-- delete, refresh,remove guid, starttimers, stoptimers handle elsewhere
