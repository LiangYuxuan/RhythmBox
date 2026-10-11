local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

-- Lua functions
local _G = _G
local string_format = string.format

-- WoW API / Variables
local C_AddOns_GetAddOnEnableState = C_AddOns.GetAddOnEnableState

local Enum_AddOnEnableState_All = Enum.AddOnEnableState.All

---@param s string
---@param ... any
function R:Print(s, ...)
    _G.DEFAULT_CHAT_FRAME:AddMessage(self.Title .. ": " .. string_format(s, ...))
end

---@param addon uiAddon
---@param character string | nil
---@return Enum.AddOnEnableState
function R:GetAddOnEnableState(addon, character)
    return C_AddOns_GetAddOnEnableState(addon, character)
end

---@param addon uiAddon
---@return boolean
function R:IsAddOnEnabled(addon)
    return self:GetAddOnEnableState(addon, self.playerGUID) == Enum_AddOnEnableState_All
end
