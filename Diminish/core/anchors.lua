local _, NS = ...

NS.anchors = {
    player = {
        "SUFUnitplayer",
        "XPerl_PlayerportraitFrame",
        "ElvUF_Player",
        "oUF_TukuiPlayer",
        "PlayerFrame", -- Blizzard frame should always be last
    },

    target = {
        "SUFUnittarget",
        "XPerl_TargetportraitFrame",
        "ElvUF_Target",
        "oUF_TukuiTarget",
        "TargetFrame",
    },

    focus = {
        "SUFUnitfocus",
        "XPerl_FocusportraitFrame",
        "ElvUF_Focus",
        "oUF_TukuiFocus",
        "FocusFrame",
    },

    party = {
        "SUFHeaderpartyUnitButton",
        "XPerl_party",
        "ElvUF_PartyGroup1UnitButton",
        "TukuiPartyUnitButton",
        --"Vd1H%dBgBarlcBarFIBar",
        "PartyMemberFrame",
    },

    --[[raid = {
        "CompactRaidFrame",
    },]]

    arena =  {
        "ElvUF_Arena",
        "TukuiArena",
        "ArenaEnemyFrame",
    },
}
