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
        "SUFHeaderpartyUnitButton",
        "XPerl_party",
        "ElvUF_PartyGroup1UnitButton",
        "TukuiPartyUnitButton",
        --"Vd1H%dBgBarlcBarFIBar",
        "DUF_PartyFrame",
        -- TODO: gw2 raid/partyframe
        -- TODO: oUF party frame + raid
        "PitBull4_Groups_PartyUnitButton",
        "PartyMemberFrame",
    },

    --[[raid = {
        "CompactRaidFrame",
    },]]

    arena =  {
        "ElvUF_Arena",
        "TukuiArena",
        --"barena%dUnitFrame",
        "ArenaEnemyFrame",
    },
}
