local _, Diminish = ...

local anchors = {
    "SUFUnitfocus",
    "XPerl_FocusportraitFrame",
    "ElvUF_Focus",
    "oUF_TukuiFocus",
    "bfocusUnitFrame",
    "DUF_FocusFrame",
    "GwFocusUnitFrame",
    "PitBull4_Frames_Focus",
    "oUF_Focus",
    "SUI_focusFrame",
    "gUI4_UnitFocus",
    "oUF_Adirelle_Focus",
    "Stuf.units.focus",
    "FocusFrame",
}

Diminish:RegisterUnitConfig("focus", anchors, {
    enabled = true,
    zones = "pvp, none, scenario",
    position = { "RIGHT", nil, 104, 23 },

    trackFriendly = false,
    trackEnemy = true,
    iconSize = 22,
    iconPadding = 7,
    iconCountdownSize = 12,
})
