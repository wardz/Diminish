local _, NS = ...

-- Third-party addon's unitframe anchors.
-- Blizzard frame should always be last.
-- Frames are cached so don't worry about performance
-- FIXME: dynamically generated frames won't work here if TestMode is ran first (arena/party)
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
        "oUF_Adirelle_Player",
        "Stuf.units.player",
        "PlayerFrame",
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
        "oUF_Adirelle_Target",
        "Stuf.units.target",
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
        "oUF_Adirelle_Focus",
        "Stuf.units.focus",
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
        "Stuf.units.party%d",
        "PartyMemberFrame%d",
    },

    arena =  {
        "ElvUF_Arena%d",
        "oUF_TukuiArena%d",
        "barena%dUnitFrame",
        "oUF_Arena%d",
        "oUF_Adirelle_Arena%d",
        "Stuf.units.arena%d",
        "ArenaEnemyFrame%d",
    },
}
