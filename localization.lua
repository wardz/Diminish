local _, NS = ...
local L = {}
NS.L = L

--[[
    Want to help Translate Diminish?
    https://wow.curseforge.com/projects/diminish/localization/
]]

L["SILENCE"] = _G.LOC_TYPE_SILENCE
L["STUN"] = _G.STUN
L["ROOT"] = _G.LOC_TYPE_ROOT
L["DISARM"] = _G.LOC_TYPE_DISARM
L["TAUNT"] = gsub(gsub(_G.EMOTE137_CMD1, "/", ""), "^%l", strupper) -- "/taunt" to "Taunt"

if strfind(GetLocale(), "en") then
    L["DISORIENT"] = "Disorient"
    L["INCAPACITATE"] = "Incapacitate"
else
    L["DISORIENT"] = _G.LOSS_OF_CONTROL_DISPLAY_DISORIENT
    L["INCAPACITATE"] = _G.LOSS_OF_CONTROL_DISPLAY_INCAPACITATE
end
