local _, NS = ...

-- How long a diminshing return lasts.
NS.DR_TIME = 18

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

-- Border/text indicator colors
NS.DR_STATES_COLORS = {
    [1] = { 0, 1, 0, 1 }, -- applied 1, green
    [2] = { 1, 1, 0, 1 }, -- yellow
    [3] = { 1, 0, 0, 1 }, -- red
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
        zones = { pvp = true, arena = false, none = true, party = false, raid = false, scenario = false },
        disabledCategories = defaultsDisabledCategories,
        watchFriendly = false,
        iconSize = 24,
        iconPadding = 6,
        growLeft = false,
        offsetY = 26,
        offsetX = 91,
    }

    NS.DEFAULT_SETTINGS = {
        timerTextSize = 11,
        timerText = true,
        timerSwipe = true,
        timerColors = false,
        displayMode = "ON_AURA_START",
        spellBookTextures = false,
        showCategoryText = false,
        colorBlind = false,
        trackNPCs = false,
        borderTexture = "Interface\\BUTTONS\\UI-Quickslot-Depress",

        unitFrames = {
            target = defaultsTarget,
            focus = defaultsTarget,

            player = {
                enabled = true,
                zones = { pvp = true, arena = true, none = true, party = false, raid = false, scenario = false  },
                disabledCategories = defaultsDisabledCategories,
                watchFriendly = true,
                iconSize = 18,
                iconPadding = 6,
                growLeft = false,
                offsetY = 21,
                offsetX = 3,
            },

            party = {
                enabled = false,
                zones = { pvp = false, arena = true, none = true, party = false, raid = false, scenario = false  },
                disabledCategories = defaultsDisabledCategories,
                watchFriendly = true,
                iconSize = 24,
                iconPadding = 6,
                growLeft = false,
                offsetY = 7,
                offsetX = 76,
            },

            arena = {
                enabled = true,
                zones = { pvp = false, arena = true, none = false, party = false, raid = false, scenario = false  },
                disabledCategories = defaultsDisabledCategories,
                iconSize = 22,
                iconPadding = 6,
                growLeft = true,
                offsetY = 20,
                offsetX = -66,
            },
        },
    }
end
