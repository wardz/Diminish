local _, NS = ...

-- Font size & position for DR category label
NS.CATEGORY_FONT = {
    font = nil, -- uses font from template instead
    size = tonumber(GetCVar("UIScale")) <= 0.75 and 11 or 9,
    x = 0,
    y = 12,
    flags = nil,
}

-- Border/text indicator colors
NS.DR_STATE_COLORS = {
    { 0, 1, 0, 1 }, -- applied 1, green
    { 1, 1, 0, 1 }, -- applied 2, yellow
    { 1, 0, 0, 1 }, -- applied 3, red
}

-------------------------------------------------------
-------------------------------------------------------

NS.categoriesList = LibStub("DRList-1.0"):GetCategories()

NS.defaultSavedVariables = {
    settingsVersion = 1,

    timerTextOutline = "NONE",
    timerText = true,
    timerSwipe = true,
    timerColors = false,
    showCategoryText = false,
    colorBlind = false,
    trackNPCs = false,

    border = {
        edgeSize = 2.5,
        edgeFile = "Interface\\BUTTONS\\UI-Quickslot-Depress",
        layer = "BORDER",
        name = _G.DEFAULT,
    },

    customTextures = {},
    unitFrames = {},
}
