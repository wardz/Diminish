local PoolManager = {}

local framePool = CreateFramePool("CheckButton", nil, nil, PoolManager.ResetterFrame)
local tablePool = {}
local frameCount = 0

local next = _G.next
local wipe = _G.wipe

function PoolManager:AcquireFrame()
    local frame, isNew = framePool:Acquire()
    frame:Hide()

    if isNew then
        frame:SetFrameStrata("HIGH")
        frame:SetFrameLevel(11)
        frame:EnableMouse(false)

        frameCount = frameCount + 1
        frame.__data = {}
    end

    return frame, isNew, frameCount
end

-- @private
function PoolManager:ResetterFrame(_, frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)

    if next(frame.__data) then
        wipe(frame.__data)
    end
end

function PoolManager:GetFramePool()
    return framePool
end

--[[function PoolManager:DebugInfo()
    print(frameCount, next(tablePool))
end]]

function PoolManager:AcquireTable()
    local t = next(tablePool) or {}
    tablePool[t] = nil -- remove from pool

    return t
end

function PoolManager:ReleaseTable(tbl)
    if tbl then
        tablePool[wipe(tbl)] = true -- add back to pool, wipe returns pointer to tbl here
    end
end

function PoolManager:ReleaseAllTables()
    -- Remove tbl refs from pool to allow garbage collecting
    -- Only use this after every tbl reference has been removed elsewhere aswell
    tablePool = {}
end
