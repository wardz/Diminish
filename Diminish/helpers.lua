local _, NS = ...

NS.Debug = function(...)
    if false then print("|cFFFF0000[D]|r" .. format(...)) end
end

NS.Info = function(...)
    if false then print("|cFFFF0000[I]|r" .. format(...)) end
end

-- Copies table values from src to dst if they don't exist in dst
NS.CopyDefaults = function(src, dst)
    if type(src) ~= "table" then return {} end
    if type(dst) ~= "table" then dst = {} end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = NS.CopyDefaults(v, dst[k])
        elseif type(v) ~= type(dst[k]) then
            dst[k] = v
        end
    end

    return dst
end

-- Find debuff duration by aura indices
local UnitAura = _G.UnitAura
NS.GetAuraDuration = function(unitID, spellID)
    if not unitID or not spellID then return end

    for i = 1, 40 do
        local _, _, _, _, duration, expirationTime, _, _, _, id = UnitAura(unitID, i, "HARMFUL")
        if not id then return end -- no more debuffs

        if spellID == id then
            return duration, expirationTime
        end
    end
end

-- Pool for reusing tables. Sacrifices slight performance for less memory usage
-- (Tables can't be garbage collected in combat)
do
    local pool = {}
    local wipe = _G.table.wipe
    local next = _G.next

    NS.NewTable = function()
        local t = next(pool) or {}
        pool[t] = nil -- disallow next() with nil

        return t
    end

    NS.RemoveTable = function(tbl)
        if tbl then
            pool[wipe(tbl)] = true -- allow next(), wipe returns pointer to tbl here
        end
    end

    NS.ReleaseTables = function()
        -- Remove tbl refs from pool to allow garbage collecting
        -- Only use this after every tbl reference has been removed elsewhere aswell
        pool = {}
    end
end
