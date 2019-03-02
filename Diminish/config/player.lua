local _, Diminish = ...

local anchors = {
    "SUFUnitplayer",
    "XPerl_PlayerportraitFrame",
    "ElvUF_Player",
    "oUF_TukuiPlayer",
    "bplayerUnitFrame",
    "DUF_PlayerFrame",
    "GwPlayerHealthGlobe",
    "PitBull4_Frames_Player",
    "oUF_Player",
    "SUI_playerFrame",
    "gUI4_UnitPlayer",
    "oUF_Adirelle_Player",
    "Stuf.units.player",
    "PlayerFrame",
}

Diminish:RegisterUnitConfig("player", anchors, {
    enabled = true,
    zones = "pvp, arena, none, scenario",
    position = { "RIGHT", nil, -6, 40 },
    disabledCategories = {},

    trackFriendly = true,
    trackEnemy = false,
    iconSize = 21,
    iconPadding = 7,
    iconCountdownSize = 12,
})
