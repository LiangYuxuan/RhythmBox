local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxMiscModule: AceAddon-3.0
local M = R:NewModule('Misc')

-- Lua functions
local ipairs = ipairs
local table_insert = table.insert

-- WoW API / Variables

---@class RhythmBoxMiscOptionsCallback
---@field module AceAddon-3.0
---@field title string

---@type RhythmBoxMiscOptionsCallback[]
local optionsCallbacks = {}

---@param module AceAddon-3.0
function M:UpdateModuleEnableStatus(module)
    local moduleName = module:GetName()
    local isEnabled = module:IsEnabled()
    local shouldEnabled = R.db.Misc[moduleName]
    if isEnabled ~= shouldEnabled then
        if shouldEnabled then
            module:Enable()
        else
            module:Disable()
        end
    end
end

---@param optionName string?
function M:UpdateEnableStatus(optionName)
    if optionName then
        ---@type AceAddon-3.0?
        local module = R:GetModule(optionName)
        if module then
            self:UpdateModuleEnableStatus(module)
        end
    else
        for _, callback in ipairs(optionsCallbacks) do
            local module = callback.module
            self:UpdateModuleEnableStatus(module)
        end
    end
end

---@param option AceConfig.OptionsTable
function M:UpdateOption(option)
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
---@class RhythmBoxMiscProfile: table<string, boolean>
P.Misc = {}

R:RegisterOptions(
    M,
    "杂项",
    ---@param optionName string?
    function(optionName)
        M:UpdateEnableStatus(optionName)
    end,
    ---@param options AceConfig.OptionsTable
    function(options)
        M:UpdateOption(options)
    end
)

---@param module AceAddon-3.0
---@param title string
function M:Register(module, title)
    local moduleName = module:GetName()
    P.Misc[moduleName] = true

    table_insert(optionsCallbacks, {
        module = module,
        title = title,
    })
end

function M:OnEnable()
    for _, callback in ipairs(optionsCallbacks) do
        local module = callback.module
        local moduleName = module:GetName()
        if not R.db.Misc[moduleName] then
            module:Disable()
        end
    end
end
