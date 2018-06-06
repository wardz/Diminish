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
        "FocusFrame",
    },

    party = {
        "SUFHeaderpartyUnitButton%d",
        "XPerl_party%d",
        "ElvUF_PartyGroup1UnitButton%d",
        "TukuiPartyUnitButton%d",
        --"Vd1H%dBgBarlcBarFIBar",
        "DUF_PartyFrame%d",
        -- TODO: gw2 raid/partyframe
        "PitBull4_Groups_PartyUnitButton%d",
        "oUF_Raid%d",
        --"GridLayoutHeader1UnitButton%d",
        "PartyMemberFrame%d",
    },

    --[[raid = {
        "CompactRaidFrame",
    },]]

    arena =  {
        "ElvUF_Arena%d",
        "TukuiArena%d",
        "barena%dUnitFrame",
        "oUF_Arena%d",
        "ArenaEnemyFrame%d",
    },
}
