local _, NS = ...

-- How long a diminshing return lasts.
-- Add 0.3 extra to account for any animation/server delay
NS.DR_TIME = 18.3

-- "enum" for categories
NS.CATEGORIES = {
    DISORIENT = NS.L.DISORIENT,
    INCAPACITATE = NS.L.INCAPACITATE,
    SILENCE = NS.L.SILENCE,
    STUN = NS.L.STUN,
    ROOT = NS.L.ROOT,
    DISARM = NS.L.DISARM,
}

-- Border indicator colors
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
        [NS.CATEGORIES.DISARM] = true
    }

    local defaultsTarget = {
        enabled = true,
        zones = { pvp = true, arena = false, none = true  },
        disabledCategories = defaultsDisabledCategories,
        watchFriendly = false,
        iconSize = 24,
        iconPadding = 6,
        growLeft = false,
        point = "CENTER", -- always has to be "CENTER" to be fully accurate, see OnDragStop @ testmode.lua
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
        borderTexture = "Interface\\BUTTONS\\UI-Quickslot-Depress",

        unitFrames = {
            target = defaultsTarget,
            focus = defaultsTarget,

            player = {
                enabled = true,
                zones = { pvp = true, arena = true, none = true },
                disabledCategories = defaultsDisabledCategories,
                watchFriendly = true,
                iconSize = 18,
                iconPadding = 6,
                growLeft = false,
                point = "CENTER",
                offsetY = 21,
                offsetX = 3,
            },

            party = {
                enabled = false,
                zones = { pvp = false, arena = true, none = true },
                disabledCategories = defaultsDisabledCategories,
                watchFriendly = true,
                iconSize = 24,
                iconPadding = 6,
                growLeft = false,
                point = "CENTER",
                offsetY = 7,
                offsetX = 76,
            },

            arena = {
                enabled = true,
                zones = { pvp = false, arena = true, none = false },
                disabledCategories = defaultsDisabledCategories,
                iconSize = 22,
                iconPadding = 6,
                growLeft = true,
                point = "CENTER",
                offsetY = 20,
                offsetX = -66,
            },
        },
    }
end
