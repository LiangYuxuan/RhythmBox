local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxProfessionModule: AceAddon-3.0 & AceEvent-3.0
local RP = R:NewModule('Profession', 'AceEvent-3.0')

-- Lua functions
local _G = _G

-- WoW API / Variables

function RP:OnInitialize()
    _G.DataProviderMixin:GenerateCallbackEvents({ 'OnValueChanged' })
end
