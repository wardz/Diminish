local _, Diminish = ...

local anchors = {
    "ElvUF_Arena%d",
    "oUF_TukuiArena%d",
    "barena%dUnitFrame",
    "oUF_Arena%d",
    "oUF_Adirelle_Arena%d",
    "Stuf.units.arena%d",
    "sArenaEnemyFrame%d",
    "ArenaEnemyFrame%d",
}

Diminish:RegisterUnitConfig("arena", anchors, {
    enabled = true,
    zones = "arena",
    position = { "LEFT", nil, -66, 20 },
    disabledCategories = {},

    trackFriendly = false,
    trackEnemy = true,
    iconSize = 22,
    iconPadding = 7,
    iconCountdownSize = 12,
})
