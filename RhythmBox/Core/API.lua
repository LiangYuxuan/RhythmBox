local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

-- Lua functions
local issecretvalue, pairs = issecretvalue, pairs

-- WoW API / Variables
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local C_SpecializationInfo_GetSpecialization = C_SpecializationInfo.GetSpecialization
local C_SpecializationInfo_GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

---@type table<Frame, Frame>
local nonPetBattleFrames = {}

---@param frame Frame
---@param parent Frame
function R:RegisterNonPetBattleFrame(frame, parent)
    nonPetBattleFrames[frame] = parent

    if C_PetBattles_IsInBattle() then
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

function R:UpdateRole()
    local role = UnitGroupRolesAssigned('player') or 'NONE'

    self.playerRole = (not issecretvalue(role) and role ~= 'NONE') and role or self.playerSpecRole or 'NONE'
end

function R:UpdateSpec()
    self.playerSpec = C_SpecializationInfo_GetSpecialization()

    if self.playerSpec then
        self.playerSpecID, self.playerSpecName, self.playerSpecDesc, self.playerSpecIcon, self.playerSpecRole = C_SpecializationInfo_GetSpecializationInfo(self.playerSpec)
    end

    self:UpdateRole()
end

function R:APIOnEnable()
    self:UpdateSpec()
end

function R:APIOnInitialize()
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'UpdateSpec')
    self:RegisterEvent('PLAYER_ROLES_ASSIGNED', 'UpdateRole')
    self:RegisterEvent('PET_BATTLE_CLOSE', 'ShowNonPetBattleFrames')
    self:RegisterEvent('PET_BATTLE_OPENING_START', 'HideNonPetBattleFrames')
end
