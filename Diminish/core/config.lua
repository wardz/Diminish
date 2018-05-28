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

-- Max categories available (not enabled)
-- Should always match NS.CATEGORIES size
NS.MAX_CATEGORIES = 6

-- Border indicator colors
NS.DR_STATES_COLORS = {
    [1] = { 0, 1, 0, 1 }, -- applied 1, green
    [2] = { 1, 1, 0, 1 }, -- yellow
    [3] = { 1, 0, 0, 1 }, -- red
}

local defaultsDisabledCategories = {
    [NS.CATEGORIES.DISARM] = true
}

local defaultsTarget = {
    enabled = true,
    zones = { pvp = true, arena = false, none = true  },
    disabledCategories = defaultsDisabledCategories,
    watchFriendly = false,
    iconSize = 26,
    iconPadding = 3,
    growLeft = false,
    point = "CENTER",
    offsetY = 26,
    offsetX = 91,
}

-- Default savedvariables
NS.DEFAULT_SETTINGS = {
    timerTextSize = 14,
    timerText = true,
    timerSwipe = true,
    timerColors = false,
    displayMode = "ON_AURA_START",
    spellBookTextures = false,
    showCategoryText = false,

    unitFrames = {
        target = defaultsTarget,
        focus = defaultsTarget,

        player = {
            enabled = false,
            zones = { pvp = true, arena = true, none = true },
            disabledCategories = defaultsDisabledCategories,
            watchFriendly = true,
            iconSize = 26,
            iconPadding = 3,
            growLeft = false,
            point = "CENTER",
            offsetY = 23,
            offsetX = 5,
        },

        party = {
            enabled = false,
            zones = { pvp = false, arena = true, none = true },
            disabledCategories = defaultsDisabledCategories,
            watchFriendly = true,
            iconSize = 26,
            iconPadding = 3,
            growLeft = false,
            point = "CENTER",
            offsetY = 7,
            offsetX = 76,
        },

        arena = {
            enabled = true,
            zones = { pvp = false, arena = true, none = false },
            disabledCategories = defaultsDisabledCategories,
            iconSize = 26,
            iconPadding = 3,
            growLeft = true,
            point = "CENTER",
            offsetY = 20,
            offsetX = -66,
        },
    },
}
