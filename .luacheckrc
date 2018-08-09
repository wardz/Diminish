std = "lua51"
max_line_length = false
exclude_files = {
	"Diminish_Options/libs/",
	".luacheckrc"
}
ignore = {
	"11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
	"11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
	"113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"211", -- Unused local variable
	"211/L", -- Unused local variable "CL"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
--	"231", -- Set but never accessed
	"311", -- Value assigned to a local variable is unused
--	"314", -- Value of a field in a table literal is unused
	"42.", -- Shadowing a local variable, an argument, a loop variable.
}
globals = {
	-- Addon globals
	"LibStub",
	"DIMINISH_NS",
	"DiminishDB",
	"ElvUI",
	"ElvUF_Party",
	"Tukui",

	-- Misc wow globals in random order
	"_G",
	"bit",
	"CreateFrame",
	"IsInInstance",
	"wipe",
	"UnitName",
	"GetCVarBool",
	"UnitGUID",
	"UnitClass",
	"strfind",
	"min",
	"max",
	"GetTime",
	"GetNumGroupMembers",
	"RequestBattlefieldScoreData",
	"GetNumBattlefieldScores",
	"COMBATLOG_OBJECT_AFFILIATION_MINE",
	"COMBATLOG_OBJECT_AFFILIATION_PARTY",
	"GetAddOnInfo",
	"IsAddOnLoaded",
	"LoadAddOn",
	"InterfaceOptionsFrame",
	"InterfaceAddOnsList_Update",
	"PanelTemplates_GetSelectedTab",
	"PanelTemplates_UpdateTabs",
	"PanelTemplates_Tab_OnClick",
	"tinsert",
	"PanelTemplates_TabResize",
	"PanelTemplates_UpdateTabs",
	"PanelTemplates_SetNumTabs",
	"PanelTemplates_SetTab",
	"GetSpellTexture",
	"SlashCmdList",
	"STANDARD_TEXT_FONT",
	"GetRealmName",
	"GetAddOnMetadata",
	"GetLocale",
	"gsub",
	"format",
	"EMPTY",
	"InCombatLockdown",
	"InActiveBattlefield",
	"IsActiveBattlefieldArena",
	"InterfaceOptionsFrame_OpenToCategory",
	"InterfaceOptionsFramePanelContainer",
	"StaticPopupDialogs",
	"OKAY",
	"StaticPopup_Show",
	"GameTooltip",
	"floor",
	"CreateFramePool",
	"strmatch",
	"SetCursor",
	"ResetCursor",
	"ArenaEnemyFrames",
	"IsInGroup",
	"UIParent",
	"UnitExists",
	"strupper",
	"tremove",
	"ceil",
	"InterfaceOptions_AddCategory",
	"InterfaceOptionsFramePanelContainter",
	"GAME_VERSION_LABEL",
	"HIGHLIGHT_FONT_COLOR_CODE",
	"ChatFontSmall",
	"GameTooltip_Hide",
	"GameFontNormalLeftGrey",
	"GameFontHighlightLeft",
	"random",
	"C_Timer",
	"CompactRaidFrameContainer",
	"strsub",
}
