local _, NS = ...

NS.anchors = {
    player = {
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
        "PlayerFrame", -- Blizzard frame should always be last
    },

    target = {
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
        "TargetFrame",
    },

    focus = {
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
        "FocusFrame",
    },

    party = {
        "SUFHeaderpartyUnitButton%d",
        "XPerl_party%d",
        "ElvUF_PartyGroup1UnitButton%d",
        "TukuiPartyUnitButton%d",
        "DUF_PartyFrame%d",
        "PitBull4_Groups_PartyUnitButton%d",
        "oUF_Raid%d",
        "GwPartyFrame%d",
        "gUI4_GroupFramesGroup5UnitButton%d",
        "PartyMemberFrame%d",
    },

    --[[raid = {
        "Vd1H%dBgBarlcBarFIBar",
        "GridLayoutHeader1UnitButton%d",
        "CompactRaidFrame%d",
    },]]

    arena =  {
        "ElvUF_Arena%d",
        "TukuiArena%d",
        "barena%dUnitFrame",
        "oUF_Arena%d",
        --"GladiusClassIconFramearena%d",
        "ArenaEnemyFrame%d",
    },
}
