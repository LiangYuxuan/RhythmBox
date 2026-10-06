local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core
local AceConsole = Engine.Libs.AceConsole
local AceDBOptions = Engine.Libs.AceDBOptions
local AceConfig = Engine.Libs.AceConfig
local AceConfigDialog = Engine.Libs.AceConfigDialog

-- Lua functions
local _G = _G
local ipairs, xpcall = ipairs, xpcall
local table_insert = table.insert

-- WoW API / Variables
local HideUIPanel = HideUIPanel
local Settings_OpenToCategory = Settings.OpenToCategory

---@class RhythmBoxOptionsTable: AceConfig.OptionsTable
---@field name string
R.Options = {
    name = R.Title,
    type = 'group',
    args = {
        General = {
            order = 1,
            type = 'group',
            childGroups = 'tree',
            name = "设置",
            args = {
                InstallAll = {
                    order = 0.1,
                    type = 'execute',
                    name = "全部设置",
                    hidden = not R.isDeveloper,
                    func = function()
                        -- TODO
                    end,
                },
                DeveloperConsole = {
                    order = 0.2,
                    type = 'execute',
                    name = "显示/隐藏控制台",
                    func = function() _G.DeveloperConsole:Toggle() end,
                },
            },
        },
    },
}

---@class RhythmBoxOptionsCallback
---@field module AceAddon-3.0
---@field title string
---@field onOptionsChanged fun(optionName: string?): nil
---@field onOptionsCreated fun(options: AceConfig.OptionsTable): nil

---@type RhythmBoxOptionsCallback[]
local optionsCallbacks = {}

---@param module AceAddon-3.0
---@param title string
---@param onOptionsChanged fun(optionName: string?): nil
---@param onOptionsCreated fun(options: AceConfig.OptionsTable): nil
function R:RegisterOptions(module, title, onOptionsChanged, onOptionsCreated)
    table_insert(optionsCallbacks, {
        module = module,
        title = title,
        onOptionsChanged = onOptionsChanged,
        onOptionsCreated = onOptionsCreated,
    })
end

function R:OptionsOnProfileUpdated()
    for _, callbackInfo in ipairs(optionsCallbacks) do
        local module = callbackInfo.module
        local moduleName = module:GetName()
        if self.db[moduleName].Enable ~= nil and (self.db[moduleName].Enable ~= module:IsEnabled()) then
            module:SetEnabledState(self.db[moduleName].Enable)
        end

        callbackInfo.onOptionsChanged()
    end
end

function R:OptionsOnEnable()
    local order = 1

    for _, callbackInfo in ipairs(optionsCallbacks) do
        local module = callbackInfo.module
        local moduleName = module:GetName()
        local onOptionsChanged = callbackInfo.onOptionsChanged

        ---@param info string[]
        ---@param key string | number | nil
        ---@return boolean | number | string
        local function getter(info, key)
            local optionName = info[#info]

            if key then
                ---@type boolean
                local value = self.db[moduleName][optionName][key]
                return value
            end

            ---@type boolean | number | string
            local value = self.db[moduleName][optionName]
            return value
        end

        ---@param info string[]
        ---@param value boolean | number | string
        ---@param key string | number | nil
        local function setter(info, value, key)
            local optionName = info[#info]

            if key then
                self.db[moduleName][optionName][key] = value
            else
                self.db[moduleName][optionName] = value
            end

            if optionName == 'Enable' then
                if value then
                    module:Enable()
                else
                    module:Disable()
                end
            else
                onOptionsChanged(optionName)
            end
        end

        ---@type AceConfig.OptionsTable
        local options = {
            order = order,
            type = 'group',
            name = callbackInfo.title,
            get = getter,
            set = setter,
        }

        self.Options.args.General.args[moduleName] = options
        order = order + 1

        xpcall(callbackInfo.onOptionsCreated, self.ErrorHandler, options)

        if self.db[moduleName].Enable == false then
            module:Disable()
        end
    end

    self.Options.args.Profile = AceDBOptions:GetOptionsTable(self.data)

    AceConfig:RegisterOptionsTable(self.Name, self.Options)

    ---@type Frame, string
    local _, categoryID = AceConfigDialog:AddToBlizOptions(self.Name, self.Title, nil, 'General')

    AceConfigDialog:AddToBlizOptions(self.Name, "配置文件", self.Title, 'Profile')

    local function ToggleConfig()
        if _G.SettingsPanel:IsShown() then
            HideUIPanel(_G.SettingsPanel)
        else
            Settings_OpenToCategory(categoryID)
        end
    end

    AceConsole:RegisterChatCommand('rb', ToggleConfig)
    AceConsole:RegisterChatCommand('rhythmbox', ToggleConfig)
end
