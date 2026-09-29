local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

-- Lua functions
local table_insert = table.insert

-- WoW API / Variables

---@type table<Frame, Frame>
local nonPetBattleFrames = {}

---@param frame Frame
---@param parent Frame
function R:RegisterNonPetBattleFrame(frame, parent)
    nonPetBattleFrames[frame] = parent

    if C_PetBattles.IsInBattle() then
        frame:SetParent(R.HiddenFrame)
    end
end

function R:HideNonPetBattleFrames()
    for frame in pairs(nonPetBattleFrames) do
        frame:SetParent(R.HiddenFrame)
    end
end

function R:ShowNonPetBattleFrames()
    for frame, parent in pairs(nonPetBattleFrames) do
        frame:SetParent(parent)
    end
end

function R:APIOnInitialize()
    self:RegisterEvent('PET_BATTLE_CLOSE', 'ShowNonPetBattleFrames')
    self:RegisterEvent('PET_BATTLE_OPENING_START', 'HideNonPetBattleFrames')
end
