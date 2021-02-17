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
    NS.CATEGORIES.knockback = nil -- unreliable to track, remove it for now
end

do
    local expansions = {
        [WOW_PROJECT_MAINLINE] = "retail",
        [WOW_PROJECT_CLASSIC] = "classic",
        [WOW_PROJECT_TBC or 3] = "tbc",
    }

    NS.IS_CLASSIC = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

    local alert = _G.message or _G.print
    local currExp = expansions[WOW_PROJECT_ID]
    local tocExp = tonumber(GetAddOnMetadata("Diminish", "X-Expansion"))
    if currExp == "classic" and tocExp ~= 2 then
        alert(format("Error: You're currently using the %s version of Diminish on a Classic client. You need to download the Classic version instead.", expansions[tocExp]))
    elseif currExp == "retail" and tocExp ~= 1 then
        alert(format("Error: You're currently using the %s version of Diminish on a Retail client. You need to download the Retail version instead.", expansions[tocExp]))
    elseif currExp == "tbc" and tocExp ~= 3 then
        alert(format("Error: You're currently using the %s version of Diminish on a TBC client. You need to download the TBC version instead.", expansions[tocExp]))
    end
end

-------------------------------------------------------
-- Default SavedVariables
-------------------------------------------------------

do
    local defaultsDisabledCategories = {}
    -- TODO: tbc
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
        version = "1.5",
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
                usePersonalNameplate = false,
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
