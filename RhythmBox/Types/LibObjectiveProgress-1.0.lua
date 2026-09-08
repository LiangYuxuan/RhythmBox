---@meta _
---@class LibObjectiveProgress-1.0
local LOP = {}

---@param mapID number
---@param npcID number
---@param isTeeming boolean?
---@param isAlternate boolean?
---@return number?
function LOP:GetNPCWeightByMap(mapID, npcID, isTeeming, isAlternate) end

---@param questID number
---@param npcID number
---@return number?
function LOP:GetNPCWeightByQuest(questID, npcID) end

---@param npcID number
---@return number?
function LOP:GetNPCWeightByCurrentQuests(npcID) end
