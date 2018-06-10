local ADDON_NAME, NS = ...

local Panel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
Panel.frames = {}
Panel:Hide()
NS.Panel = Panel

local function RefreshOnShow(self)
    if self.refresh then
        self.refresh(self)
    end
end

local function OnShow(self)
    if not Panel.initialized then
        -- Create all frames when our optionsframe gets shown
        if Panel.Setup then
            Panel:Setup()
            Panel.Setup = nil
        end

        if Panel.callbacks then
            for i = 1, #Panel.callbacks do
                Panel.callbacks[i]()
                Panel.callbacks[i] = nil
            end
            Panel.callbacks = nil
        end

        -- allow garbage collection of widgets
        -- since we dont need them any more after initialization (except ToggleState())
        for k, v in pairs(NS.Widgets) do
            if k ~= "ToggleState" then
                NS.Widgets[k] = nil
            end
        end

        Panel.CreateChild = nil
        Panel.initialized = true
    end

    RefreshOnShow(self)

    if InCombatLockdown() then return end

    -- Display child panels when clicking main panel
    local i, target = 1, Panel.name
    while true do
        local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
        if not button then break end
        local element = button.element
        if element and element.name == target then
            if element.hasChildren and element.collapsed then
                _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
            end
            return
        end
        i = i + 1
    end
end

function Panel:Register()
    self.name = ADDON_NAME

    self:SetScript("OnShow", OnShow)
    if self:IsShown() then
        OnShow(self)
    end

    InterfaceOptions_AddCategory(self)
    self.Register = nil
end

function Panel:CreateChild(name, callback)
    assert(type(name) == "string")
    assert(type(callback) == "function")

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

        callback(panel)
        panel:SetScript("OnShow", RefreshOnShow)
    end
end

Panel:Register()
