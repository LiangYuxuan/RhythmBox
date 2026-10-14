local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxInjectionsModule: AceAddon-3.0 & AceEvent-3.0
local RI = R:NewModule('Injections', 'AceEvent-3.0')
RI:SetDefaultModuleState(false)

-- Lua functions
local ipairs, next, pairs, xpcall = ipairs, next, pairs, xpcall
local table_insert = table.insert

-- WoW API / Variables
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

---@class RhythmBoxInjectionsOptionsCallback
---@field module AceAddon-3.0
---@field title string

---@type RhythmBoxInjectionsOptionsCallback[]
local optionsCallbacks = {}

---@type table<AceAddon-3.0, table<string, true>>
local addonCallbacks = {}

---@param module AceAddon-3.0
function RI:OnModuleAddonReady(module)
    if module.OnAddonLoad then
        xpcall(module.OnAddonLoad, R.ErrorHandler, module)
    end

    local moduleName = module:GetName()
    if R.db.Injections[moduleName] then
        module:Enable()
    elseif module.OnDisable then
        xpcall(module.OnDisable, R.ErrorHandler, module)
    end
end

---@param _ string
---@param addonName string
function RI:OnAddonLoaded(_, addonName)
    for module, addons in pairs(addonCallbacks) do
        if addons[addonName] then
            addons[addonName] = nil
            if not next(addons) then
                addonCallbacks[module] = nil
                self:OnModuleAddonReady(module)
            end
        end
    end
end

---@param module AceAddon-3.0
function RI:UpdateModuleEnableStatus(module)
    if addonCallbacks[module] then return end

    local moduleName = module:GetName()
    local isEnabled = module:IsEnabled()
    local shouldEnabled = R.db.Injections[moduleName]
    if isEnabled ~= shouldEnabled then
        if shouldEnabled then
            module:Enable()
        else
            module:Disable()
        end
    end
end

---@param optionName string?
function RI:UpdateEnableStatus(optionName)
    if optionName then
        ---@type AceAddon-3.0?
        local module = self:GetModule(optionName)
        if module then
            self:UpdateModuleEnableStatus(module)
        end
    else
        for moduleName, status in pairs(R.db.Injections) do
            ---@type AceAddon-3.0?
            local module = self:GetModule(moduleName, true)
            if module then
                self:UpdateModuleEnableStatus(module)
            end
        end
    end
end

---@param option AceConfig.OptionsTable
function RI:UpdateOption(option)
    option.args = {}

    local order = 1
    for _, callback in ipairs(optionsCallbacks) do
        local moduleName = callback.module:GetName()

        option.args[moduleName] = {
            order = order,
            type = 'toggle',
            name = callback.title,
        }

        order = order + 1
    end
end

---@class RhythmBoxProfile
local P = Engine.Profile
---@class RhythmBoxInjectionsProfile: table<string, boolean>
P.Injections = {}

R:RegisterOptions(
    RI,
    "注入",
    ---@param optionName string?
    function(optionName)
        RI:UpdateEnableStatus(optionName)
    end,
    ---@param options AceConfig.OptionsTable
    function(options)
        RI:UpdateOption(options)
    end
)

---@param module AceAddon-3.0
---@param title string
---@param requiredAddons table<string, true>?
---@param optionalAddons table<string, true>?
function RI:Register(module, title, requiredAddons, optionalAddons)
    local moduleName = module:GetName()
    P.Injections[moduleName] = true

    table_insert(optionsCallbacks, {
        module = module,
        title = title,
    })

    ---@type table<string, true>
    local addons = {}
    if requiredAddons then
        for addon in pairs(requiredAddons) do
            addons[addon] = true
        end
    end
    if optionalAddons then
        for addon in pairs(optionalAddons) do
            if R:IsAddOnEnabled(addon) then
                addons[addon] = true
            end
        end
    end

    addonCallbacks[module] = addons
end

function RI:OnEnable()
    for module, addons in pairs(addonCallbacks) do
        for addon in pairs(addons) do
            if C_AddOns_IsAddOnLoaded(addon) then
                addons[addon] = nil
            end
        end

        if not next(addons) then
            addonCallbacks[module] = nil
            self:OnModuleAddonReady(module)
        end
    end

    self:RegisterEvent('ADDON_LOADED', 'OnAddonLoaded')
end
