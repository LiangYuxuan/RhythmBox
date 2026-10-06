local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

-- Lua functions
local _G = _G
local string_format = string.format

-- WoW API / Variables

---@param s string
---@param ... any
function R:Print(s, ...)
    _G.DEFAULT_CHAT_FRAME:AddMessage(R.Title .. ": " .. string_format(s, ...))
end
