local _, NS = ...

-- How long a diminishing return lasts.
NS.DR_TIME = 18.5

-- Font size & position for DR indicator text
NS.INDICATOR_FONT = {
    size = false, -- use automatic size
    x = 0,
    y = 0,
}

-- Font size & position for DR category label
NS.CATEGORY_FONT = {
    size = 9,
    x = 0,
    y = 12,
}

-- Border/text indicator colors
NS.DR_STATES_COLORS = {
    { 0, 1, 0, 1 }, -- applied 1, green
    { 1, 1, 0, 1 }, -- applied 2, yellow
    { 1, 0, 0, 1 }, -- applied 3, red
}

-- Indicator texts (1/2, 3/4, x)
NS.DR_STATES_TEXT = { "\194\189", "\194\190", "x" }

-- "enum" for categories
NS.CATEGORIES = {
    DISORIENT = NS.L.DISORIENT,
    INCAPACITATE = NS.L.INCAPACITATE,
    SILENCE = NS.L.SILENCE,
    STUN = NS.L.STUN,
    ROOT = NS.L.ROOT,
    DISARM = NS.L.DISARM,
    TAUNT = NS.L.TAUNT,
}

-------------------------------------------------------
-- Default SavedVariables
-------------------------------------------------------

do
    local defaultsDisabledCategories = {
        [NS.CATEGORIES.DISARM] = true,
        [NS.CATEGORIES.TAUNT] = true,
    }

    local defaultsTarget = {
        enabled = true,
        zones = {
            pvp = true, arena = false, none = true,
            party = false, raid = false, scenario = true,
        },
        disabledCategories = defaultsDisabledCategories,
        anchorUIParent = false,
        watchFriendly = false,
        iconSize = 24,
        iconPadding = 6,
        growDirection = "RIGHT",
        offsetY = 26,
        offsetX = 91,
    }

    NS.DEFAULT_SETTINGS = {
        timerTextSize = 11,
        timerText = true,
        timerSwipe = true,
        timerColors = false,
        timerStartAuraEnd = false,
        spellBookTextures = false,
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
            target = defaultsTarget,
            focus = defaultsTarget,

            player = {
                enabled = true,
                zones = {
                    pvp = true, arena = true, none = true,
                    party = false, raid = false, scenario = true,
                },
                disabledCategories = defaultsDisabledCategories,
                anchorUIParent = false,
                watchFriendly = true,
                iconSize = 22,
                iconPadding = 6,
                growDirection = "RIGHT",
                offsetY = 26,
                offsetX = 8,
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
                iconPadding = 6,
                growDirection = "LEFT",
                offsetY = 20,
                offsetX = -66,
            },

            nameplate = {
                enabled = false,
                zones = {
                    pvp = true, arena = true, none = true,
                    party = false, raid = false, scenario = true,
                },
                disabledCategories = defaultsDisabledCategories,
                watchFriendly = false,
                iconSize = 18,
                iconPadding = 6,
                growDirection = "TOP",
                offsetY = 24,
                offsetX = 74,
            },
        },
    }
end
