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
-- too lazy to rename keys at this point, otherwise we could just do NS.CATEGORIES = DRList:GetCategories()
NS.CATEGORIES = {
    INCAPACITATE = DRList:GetCategories().incapacitate,
    SILENCE = DRList:GetCategories().silence,
    STUN = DRList:GetCategories().stun,
    ROOT = DRList:GetCategories().root,
    DISARM = DRList:GetCategories().disarm,

    --@retail@
    DISORIENT = DRList:GetCategories().disorient,
    TAUNT = DRList:GetCategories().taunt,
    --@end-retail@

    --@non-retail@
    CHARGE = DRList:GetCategories().charge,
    OPENER_STUN = DRList:GetCategories().opener_stun,
    RANDOM_STUN = DRList:GetCategories().random_stun,
    RANDOM_ROOT = DRList:GetCategories().random_root,
    FEAR = DRList:GetCategories().fear,
    FROST_SHOCK = DRList:GetCategories().frost_shock,
    MIND_CONTROL = DRList:GetCategories().mind_control,
    --@end-non-retail@
}

-------------------------------------------------------
-- Default SavedVariables
-------------------------------------------------------

do
    local defaultsDisabledCategories = {
        --@retail@
        [NS.CATEGORIES.DISARM] = true,
        [NS.CATEGORIES.TAUNT] = true,
        --@end-retail@

        --@non-retail@
        [NS.CATEGORIES.FROST_SHOCK] = true,
        [NS.CATEGORIES.MIND_CONTROL] = true,
        --@end-non-retail@
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
        --@retail@
        timerStartAuraEnd = false, -- luacheck: ignore
        --@end-retail@
        --@non-retail@
        timerStartAuraEnd = true,
        --@end-non-retail@
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
end
