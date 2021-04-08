local _, NS = ...
local Widgets = NS.Widgets

local function RefreshOnShow(self)
    if self.refresh then
        self.refresh(self)
    end
end

local function InitializePanel(self)
    if self.initialized then return end

    -- Create all frames when our options frame gets shown
    if self.Setup then
        self:Setup()
        self.Setup = nil
    end

    -- Create all child panel frames
    if self.callbacks then
        for i = 1, #self.callbacks do
            self.callbacks[i]()
            self.callbacks[i] = nil
        end
        self.callbacks = nil

        if InCombatLockdown() then
            -- If we don't do this then child buttons (InterfaceOptionsFrameAddOnsButtonXToggle)
            -- won't be shown when you initialize the panel in combat
            InterfaceOptionsFrame_OpenToCategory(self.lastCreatedChild)
            InterfaceOptionsFrame_OpenToCategory(self)
        end
    end

    -- allow garbage collection of widget methods
    -- since we dont need them any more after initialization
    for k, v in pairs(NS.Widgets) do
        if strfind(k, "Create") then -- make sure helper functions are not deleted
            NS.Widgets[k] = nil
        end
    end

    self.CreateChild = nil
    self.initialized = true
end

local function OnShow(self)
    InitializePanel(self)
    RefreshOnShow(self)

    if InCombatLockdown() then return end

    -- Display child panel buttons when clicking main panel
    local i = 1
    while true do
        local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
        if not button then break end

        local element = button.element
        if element and element.name == self.name then
            if element.hasChildren and element.collapsed then
                _G[button:GetName().."Toggle"]:Click()
            end
            return
        end
        i = i + 1
    end
end

-- Create child panel for main panel
local function CreateChildPanel(self, name, callback)
    if not self.callbacks then
        self.callbacks = {}
    end

    -- Schedule creation for main Panel OnShow
    self.callbacks[#self.callbacks + 1] = function()
        local panel = CreateFrame("Frame", nil, self)
        panel.name = name
        panel.parent = self.name
        panel.frames = {}
        InterfaceOptions_AddCategory(panel)
        self.lastCreatedChild = panel

        callback(panel)
        panel:SetScript("OnShow", RefreshOnShow)
    end
end

--InterfaceOptionsFrameCategoriesTop = InterfaceOptionsFrameCategories.TopEdge;
--InterfaceOptionsFrameAddOnsTop = InterfaceOptionsFrameAddOns.TopEdge;

function Widgets:CreateMainPanel(name)
    self.ADDON_NAME = name

    local panel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
    panel.name = name
    panel.frames = {}
    panel.CreateChildPanel = CreateChildPanel
    panel:Hide()

    InterfaceOptions_AddCategory(panel)
    panel:SetScript("OnShow", OnShow)
    return panel
end

