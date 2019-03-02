local _, Diminish = ...

Diminish:RegisterUnitConfig("arena", nil, {
    enabled = false,
    zones = "pvp, arena, none, scenario",
    position = { "RIGHT", nil, -33, 71 },
    disabledCategories = {},

    trackFriendly = false,
    trackEnemy = true,
    iconSize = 22,
    iconPadding = 7,
    iconCountdownSize = 12,
})
