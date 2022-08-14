local _, NS = ...
local DRList = LibStub("DRList-1.0")

-- How long a diminishing return lasts.
NS.DR_TIME = DRList:GetResetTime()

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
        [WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5] = "tbc",
        [6] = "wrath", -- FIXME: temp until new constant is added
    }

    local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
    local isTBC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
    local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    local isWotlk = false

    local tocVersion = select(4, GetBuildInfo())
    if tocVersion >= 30400 and tocVersion < 40000 then
        isTBC = false
        isWotlk = true -- FIXME: temporary check for wotlk build until new constant is added
    end

    NS.IS_CLASSIC = isClassic -- Is vanilla
    NS.IS_NOT_RETAIL = isClassic or isTBC or isWotlk

    local alert = _G.message or _G.print
    local tocExp = tonumber(GetAddOnMetadata("Diminish", "X-Expansion"))
    if isClassic and tocExp ~= 2 then
        alert(format("Error: You're currently using the %s version of Diminish on a Classic client. You need to download the Classic version instead.", expansions[tocExp]))
    elseif isRetail and tocExp ~= 1 then
        alert(format("Error: You're currently using the %s version of Diminish on a Retail client. You need to download the Retail version instead.", expansions[tocExp]))
    elseif isTBC and tocExp ~= 5 then
        alert(format("Error: You're currently using the %s version of Diminish on a TBC client. You need to download the TBC version instead.", expansions[tocExp]))
    elseif isWotlk and tocExp ~= 6 then
        alert(format("Error: You're currently using the %s version of Diminish on a Wotlk client. You need to download the Wotlk version instead.", expansions[tocExp]))
    end
end

-------------------------------------------------------
-- Default SavedVariables
-------------------------------------------------------

do
    local defaultsDisabledCategories = {}

    if NS.IS_CLASSIC then
        defaultsDisabledCategories[NS.CATEGORIES.frost_shock] = true
    end

    --@retail@
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
        version = "1.10",
        timerTextOutline = "NONE",
        timerText = true,
        timerSwipe = true,
        timerEdge = false,
        timerColors = false,
        timerStartAuraEnd = false,
        showCategoryText = false,
        categoryTextMaxLines = 2,
        colorBlind = false,
        trackNPCs = false,
        categoryTextures = {},
        border = {
            edgeSize = 2.5,
            edgeFile = "Interface\\BUTTONS\\UI-Quickslot-Depress",
            layer = "BORDER",
            name = "Default",
        },
        categoryFont = {
            font = nil, -- uses font from template instead
            size = tonumber(GetCVar("UIScale")) <= 0.75 and 11 or 9,
            x = 0,
            --y = 12,
            flags = nil,
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
        NS.DEFAULT_SETTINGS.unitFrames.focus.enabled = false
        NS.DEFAULT_SETTINGS.unitFrames.arena.enabled = false
    end
end
