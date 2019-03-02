local _, Diminish = ...

local anchors = {
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
}

Diminish:RegisterUnitConfig("party", anchors, {
    enabled = false,
    zones = "arena, none",
    position = { "RIGHT", nil, 76, 7 },
    disabledCategories = {},

    trackFriendly = true,
    trackEnemy = false,
    iconSize = 24,
    iconPadding = 6,
    iconCountdownSize = 12,
})
