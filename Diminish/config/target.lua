local _, Diminish = ...

local anchors = {
    "SUFUnittarget",
    "XPerl_TargetportraitFrame",
    "ElvUF_Target",
    "oUF_TukuiTarget",
    "btargetUnitFrame",
    "DUF_TargetFrame",
    "GwTargetUnitFrame",
    "PitBull4_Frames_Target",
    "oUF_Target",
    "SUI_targetFrame",
    "gUI4_UnitTarget",
    "oUF_Adirelle_Target",
    "Stuf.units.target",
    "TargetFrame",
}

Diminish:RegisterUnitConfig("target", anchors, {
    enabled = true,
    zones = "pvp, none, scenario",
    position = { "RIGHT", nil, 104, 23 },
    disabledCategories = {},

    trackFriendly = false,
    trackEnemy = true,
    iconSize = 22,
    iconPadding = 7,
    iconCountdownSize = 12,
})
