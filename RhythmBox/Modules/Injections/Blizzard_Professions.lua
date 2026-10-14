local _, Engine = ...
local R = Engine.Core
---@type RhythmBoxInjectionsModule
local RI = R:GetModule('Injections')
---@class RhythmBoxInjectionsModule.Blizzard_Professions: AceAddon-3.0
local Module = RI:NewModule('Blizzard_Professions')
RI:Register(Module, "PTR: 一键学习专业专精", { 'Blizzard_Professions' })

-- Lua functions
local _G = _G
local ipairs = ipairs

-- WoW API / Variables
local C_ProfSpecs_GetConfigIDForSkillLine = C_ProfSpecs.GetConfigIDForSkillLine
local C_ProfSpecs_GetSpecTabIDsForSkillLine = C_ProfSpecs.GetSpecTabIDsForSkillLine
local C_ProfSpecs_GetTabInfo = C_ProfSpecs.GetTabInfo
local C_Traits_GetNodeInfo = C_Traits.GetNodeInfo
local C_Traits_PurchaseRank = C_Traits.PurchaseRank
local IsPublicTestClient = IsPublicTestClient

---@param configID number
---@param nodeID number
local function Purchase(configID, nodeID)
    local nodeInfo = C_Traits_GetNodeInfo(configID, nodeID)
    ---@diagnostic disable-next-line: redundant-condition
    if nodeInfo then
        for _ = nodeInfo.ranksPurchased, nodeInfo.maxRanks do
            C_Traits_PurchaseRank(configID, nodeID)
        end

        for _, edgeInfo in ipairs(nodeInfo.visibleEdges) do
            Purchase(configID, edgeInfo.targetNode)
        end
    end
end

local function ButtonOnClick()
    local specPage = _G.ProfessionsFrame.SpecPage
    ---@type number
    local professionID = specPage:GetProfessionID()
    local configID = C_ProfSpecs_GetConfigIDForSkillLine(professionID)
    local treeIDs = C_ProfSpecs_GetSpecTabIDsForSkillLine(professionID)

    for _, treeID in ipairs(treeIDs) do
        local tabInfo = C_ProfSpecs_GetTabInfo(treeID)
        if tabInfo then
            Purchase(configID, tabInfo.rootNodeID)
        end
    end

    specPage.TreePreview:Hide()
end

function Module:OnDisable()
    if self.button then
        self.button:Hide()
    end
end

function Module:OnEnable()
    if self.button then
        self.button:Show()
    end
end

function Module:OnAddonLoad()
    ---@type Button!
    self.button = nil

    if IsPublicTestClient() then
        self.button = R:CreateTextButton(_G.ProfessionsFrame.SpecPage)
        self.button:ClearAllPoints()
        self.button:SetPoint('TOPRIGHT', -10, -40)
        self.button:SetSize(160, 36)
        self.button:SetText("学习全部专精")
        self.button:SetScript('OnClick', ButtonOnClick)
    end
end
