local _, NS = ...
local DRList = LibStub("DRList-1.0")

-- How long a diminishing return lasts.
NS.DR_TIME = DRList:GetResetTime()

-- Font size & position for DR category label
NS.CATEGORY_FONT = {
    font = nil, -- uses font from template instead
    size = tonumber(GetCVar("UIScale")) <= 0.75 and 11 or 9,
    x = 0,
    y = 12,
    flags = nil,
}

-- Border/text indicator colors
NS.DR_STATES_COLORS = {
    { 0, 1, 0, 1 }, -- applied 1, green
    { 1, 1, 0, 1 }, -- applied 2, yellow
    { 1, 0, 0, 1 }, -- applied 3, red
}

-------------------------------------------------------
-------------------------------------------------------

-- "enum" for categories
NS.CATEGORIES = CopyTable(DRList:GetCategories())
if NS.CATEGORIES.knockback then
    NS.CATEGORIES.knockback = nil
end

NS.IS_CLASSIC = select(4, GetBuildInfo()) < 80000

local alert = _G.message or _G.print
if NS.IS_CLASSIC and GetAddOnMetadata("Diminish", "X-Classic") == "0" then
    alert("Diminish: You're currently using the Retail version of Diminish on a Classic client. You should download the Classic version instead for it to work.")
elseif not NS.IS_CLASSIC and GetAddOnMetadata("Diminish", "X-Classic") == "1" then
    alert("Diminish: You're currently using the Classic version of Diminish on a Retail client. You should download the Retail version instead for it to work.")
end

-------------------------------------------------------
-- Default SavedVariables
-------------------------------------------------------

do
    local defaultsDisabledCategories = {}
    if NS.IS_CLASSIC then -- @non-retail@ filter doesn't work at the time of writing this
        defaultsDisabledCategories[NS.CATEGORIES.frost_shock] = true
        defaultsDisabledCategories[NS.CATEGORIES.mind_control] = true
    end

    --@retail@
    defaultsDisabledCategories[NS.CATEGORIES.disarm] = true
    defaultsDisabledCategories[NS.CATEGORIES.taunt] = true
    --@end-retail@

    local defaultsTarget = {
        enabled = true,
        zones = {
            pvp = true, arena = false, none = true,
            party = false, raid = false, scenario = true,
        },
        disabledCategories = defaultsDisabledCategories,
        anchorUIParent = false,
        watchFriendly = false,
        iconSize = 22,
        iconPadding = 7,
        growDirection = "RIGHT",
        offsetY = 23,
        offsetX = 104,
        timerTextSize = 12,
    }

    NS.DEFAULT_SETTINGS = {
        version = "1.4",
        timerTextOutline = "NONE",
        timerText = true,
        timerSwipe = true,
        timerColors = false,
        timerStartAuraEnd = false,
        showCategoryText = false,
        colorBlind = false,
        trackNPCs = false,
        categoryTextures = {},
        border = {
            edgeSize = 2.5,
            edgeFile = "Interface\\BUTTONS\\UI-Quickslot-Depress",
            layer = "BORDER",
            name = "Default",
        },

        unitFrames = {
            target = CopyTable(defaultsTarget),
            focus = CopyTable(defaultsTarget),

            player = {
                enabled = true,
                zones = {
                    pvp = true, arena = true, none = true,
                    party = false, raid = false, scenario = true,
                },
                disabledCategories = defaultsDisabledCategories,
                anchorUIParent = false,
                watchFriendly = true,
                iconSize = 21,
                iconPadding = 7,
                growDirection = "RIGHT",
                offsetY = 40,
                offsetX = -6,
                timerTextSize = 12,
            },

            party = {
                enabled = false,
                zones = {
                    pvp = false, arena = true, none = true,
                    party = false, raid = false, scenario = false,
                },
                disabledCategories = defaultsDisabledCategories,
                anchorUIParent = false,
                watchFriendly = true,
                iconSize = 24,
                iconPadding = 6,
                growDirection = "RIGHT",
                offsetY = 7,
                offsetX = 76,
                timerTextSize = 12,
            },

            arena = {
                enabled = true,
                zones = {
                    pvp = false, arena = true, none = false,
                    party = false, raid = false, scenario = false,
                },
                disabledCategories = defaultsDisabledCategories,
                anchorUIParent = false,
                iconSize = 22,
                iconPadding = 7,
                growDirection = "LEFT",
                offsetY = 20,
                offsetX = -66,
                timerTextSize = 12,
            },

            nameplate = {
                enabled = false,
                zones = {
                    pvp = true, arena = true, none = true,
                    party = false, raid = false, scenario = true,
                },
                disabledCategories = defaultsDisabledCategories,
                watchFriendly = false,
                iconSize = 22,
                iconPadding = 7,
                growDirection = "RIGHT",
                offsetY = 71,
                offsetX = -33,
                timerTextSize = 12,
            },
        },
    }

    if NS.IS_CLASSIC then
        NS.DEFAULT_SETTINGS.timerStartAuraEnd = true
        NS.DEFAULT_SETTINGS.unitFrames.arena.enabled = false
        NS.DEFAULT_SETTINGS.unitFrames.focus.enabled = false
    end
end
