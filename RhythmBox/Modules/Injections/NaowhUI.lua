local _, Engine = ...
local R = Engine.Core
---@type RhythmBoxInjectionsModule
local RI = R:GetModule('Injections')
---@class RhythmBoxInjectionsModule.NaowhUI: AceAddon-3.0 & AceEvent-3.0 & AceHook-3.0
local Module = RI:NewModule('NaowhUI', 'AceEvent-3.0', 'AceHook-3.0')
RI:Register(Module, "NaowhUI", { 'NaowhUI' })

-- Lua functions
local _G = _G
local ipairs = ipairs
local string_match = string.match

-- WoW API / Variables
local C_EditMode_GetLayouts = C_EditMode.GetLayouts
local C_EditMode_SetActiveLayout = C_EditMode.SetActiveLayout

---@type number
local Enum_EditModePresetLayoutsMeta_NumValues = Enum.EditModePresetLayoutsMeta.NumValues

local classSpecMap = {
    {
        -- Warrior
        'Arms',
        'Fury',
        'Protection',
    },
    {
        -- Paladin
        'Holy',
        'Protection',
        'Retribution',
    },
    {
        -- Hunter
        'Beast Mastery',
        'Marksmanship',
        'Survival',
    },
    {
        -- Rogue
        'Assassination',
        'Outlaw',
        'Subtlety',
    },
    {
        -- Priest
        'Discipline',
        'Holy',
        'Shadow',
    },
    {
        -- Death Knight
        'Blood',
        'Frost',
        'Unholy',
    },
    {
        -- Shaman
        'Elemental',
        'Enhancement',
        'Restoration',
    },
    {
        -- Mage
        'Arcane',
        'Fire',
        'Frost',
    },
    {
        -- Warlock
        'Affliction',
        'Demonology',
        'Destruction',
    },
    {
        -- Monk
        'Brewmaster',
        'Mistweaver',
        'Windwalker',
    },
    {
        -- Druid
        'Balance',
        'Feral',
        'Guardian',
        'Restoration',
    },
    {
        -- Demon Hunter
        'Havoc',
        'Vengeance',
        'Devourer',
    },
    {
        -- Evoker
        'Devastation',
        'Preservation',
        'Augmentation',
    },
}

---@param layoutInfo EditModeLayouts
local function LoadEditModeLayout(layoutInfo)
    if layoutInfo.activeLayout > Enum_EditModePresetLayoutsMeta_NumValues then
        ---@type number
        local layoutIndex = layoutInfo.activeLayout - Enum_EditModePresetLayoutsMeta_NumValues
        local layout = layoutInfo.layouts[layoutIndex]

        if layout and layout.layoutName == 'Naowh' then
            return
        end
    end

    for index, layout in ipairs(layoutInfo.layouts) do
        if layout.layoutName == 'Naowh' then
            C_EditMode_SetActiveLayout(Enum_EditModePresetLayoutsMeta_NumValues + index)
        end
    end
end

---@param event string
---@param layoutInfo EditModeLayouts
function Module:UpdateEditMode(event, layoutInfo)
    if event == 'EDIT_MODE_LAYOUTS_UPDATED' then
        LoadEditModeLayout(layoutInfo)
    elseif event == 'PLAYER_SPECIALIZATION_CHANGED' then
        LoadEditModeLayout(C_EditMode_GetLayouts())
    end
end

---@param ... any
---@return nil
---@diagnostic disable-next-line: unused-function
function Module:Blizzard_CooldownViewer(...)
    ---@type CooldownViewerLayoutManagerMixin
    local layoutManager = _G.CooldownViewerSettings:GetLayoutManager()
    local currentSpecTag = layoutManager:GetCurrentSpecTag()
    for layoutID in layoutManager:EnumerateLayouts() --[[@as fun(): number, { layoutName: string }]] do
        layoutManager:RemoveLayout(layoutID)
    end

    ---@type nil
    local result = self.hooks[self.SE].Blizzard_CooldownViewer(...)

    local specNames = classSpecMap[R.playerClassID]
    for _, layout in layoutManager:EnumerateLayouts() --[[@as fun(): number, { layoutName: string }]] do
        for specIndex, specName in ipairs(specNames) do
            if string_match(layout.layoutName, specName) then
                local specTag = R.playerClassID * 10 + specIndex
                layoutManager:SetPreviouslyActiveLayoutByName(layout.layoutName, specTag)

                if specTag == currentSpecTag then
                    layoutManager:SetActiveLayout(layout)
                end
            end
        end
    end

    layoutManager:SaveLayouts()

    return result
end

function Module:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

function Module:OnEnable()
    self:RawHook(self.SE, 'Blizzard_CooldownViewer')

    self:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED', 'UpdateEditMode')
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'UpdateEditMode')

    LoadEditModeLayout(C_EditMode_GetLayouts())
end

function Module:OnAddonLoad()
    ---@type AceAddon-3.0
    ---@diagnostic disable-next-line: undefined-field
    self.SE = (_G.NaowhUI)[1]:GetModule('Setup')
end
