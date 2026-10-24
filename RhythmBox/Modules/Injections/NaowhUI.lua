local _, Engine = ...
local R = Engine.Core
---@type RhythmBoxInjectionsModule
local RI = R:GetModule('Injections')
---@class RhythmBoxInjectionsModule.NaowhUI: AceAddon-3.0 & AceEvent-3.0 & AceHook-3.0
local Module = RI:NewModule('NaowhUI', 'AceEvent-3.0', 'AceHook-3.0')
RI:Register(Module, "NaowhUI", { 'NaowhUI', 'EllesmereUI' })

-- Lua functions
local _G = _G
local ipairs = ipairs
local string_match = string.match

-- WoW API / Variables
local C_EditMode_GetLayouts = C_EditMode.GetLayouts
local C_EditMode_SetActiveLayout = C_EditMode.SetActiveLayout

---@type number
local Enum_EditModePresetLayoutsMeta_NumValues = Enum.EditModePresetLayoutsMeta.NumValues

---@class EllesmereUI
---@field SaveBarPosition fun(key: string, point: string, relPoint: string, x: number, y: number)
---@field ReapplyAllUnlockAnchorsForced fun()
---@field RefreshAllAddons fun(budgeted: boolean?)

---@class EllesmereUIDB.ClickCast.Binding
---@field enabled boolean
---@field smartRez boolean
---@field oocOnly boolean
---@field type string
---@field key string

---@class EllesmereUIDB.ClickCast
---@field enabled boolean
---@field allFrames boolean
---@field downClick boolean
---@field globals EllesmereUIDB.ClickCast.Binding[]
---@field specs EllesmereUIDB.ClickCast.Binding[]

---@class EllesmereUIDB.Font
---@field global string
---@field outlineMode string
---@field unitNameFont string
---@field unitNameFontPath string
---@field neverShowSlug boolean
---@field applyToAllGameText boolean

---@class EllesmereUIDB.Profile.Addons.ActionBars.Bar
---@field _savedBarAlpha number?
---@field alwaysHidden boolean
---@field alwaysShowButtons boolean
---@field barVisibility string
---@field buttonHeight number
---@field buttonWidth number
---@field combatHideEnabled number
---@field combatShowEnabled number
---@field growDirection string
---@field mouseoverAlpha number
---@field mouseoverEnabled boolean
---@field orientation string?
---@field overrideNumRows number
---@field _matchExtraPixels number?

---@class EllesmereUIDB.Profile.Addons.ActionBars
---@field bars table<string, EllesmereUIDB.Profile.Addons.ActionBars.Bar>
---@field barPositions table<string, EllesmereUIDB.Profile.SpecUnlockOverrides.Layout.Point>

---@class EllesmereUIDB.Profile.Addons.Bags
---@field bagDisplayBindType boolean
---@field bagWindowLocked boolean
---@field bankWindowLocked boolean

---@class EllesmereUIDB.Profile.Addons.Chat
---@field persistChatHistory boolean
---@field timestampAll boolean
---@field timestampFormat string

---@class EllesmereUIDB.Profile.Addons.DamageMeters
---@field spellHistory { iconEnabled: boolean }

---@class EllesmereUIDB.Profile.Addons
---@field EllesmereUIActionBars EllesmereUIDB.Profile.Addons.ActionBars
---@field EllesmereUIBags EllesmereUIDB.Profile.Addons.Bags
---@field EllesmereUIChat { chat: EllesmereUIDB.Profile.Addons.Chat }
---@field EllesmereUIDamageMeters { dm: EllesmereUIDB.Profile.Addons.DamageMeters }

---@class EllesmereUIDB.Profile.UnlockLayout.Anchor
---@field target string
---@field side string
---@field offsetX number
---@field offsetY number

---@class EllesmereUIDB.Profile.SpecUnlockOverrides.Layout.Point
---@field point string
---@field relPoint string
---@field x number
---@field y number
---@field tgtB number?
---@field tgtL number?
---@field tgtR number?
---@field tgtT number?
---@field tgtx number?
---@field tgty number?

---@class EllesmereUIDB.Profile.SpecUnlockOverrides.Layout
---@field abGrow table<string, string>
---@field abPos table<string, EllesmereUIDB.Profile.SpecUnlockOverrides.Layout.Point>
---@field anchors table<string, EllesmereUIDB.Profile.UnlockLayout.Anchor>
---@field cdmGrow table<string, string>
---@field cdmPos table<string, EllesmereUIDB.Profile.SpecUnlockOverrides.Layout.Point>
---@field elems table<string, EllesmereUIDB.Profile.SpecUnlockOverrides.Layout.Point>

---@class EllesmereUIDB.Profile.SpecUnlockOverrides
---@field baselineLayout EllesmereUIDB.Profile.SpecUnlockOverrides.Layout
---@field layouts table<number, EllesmereUIDB.Profile.SpecUnlockOverrides.Layout>

---@class EllesmereUIDB.Profile.UnlockLayout
---@field anchors table<string, EllesmereUIDB.Profile.UnlockLayout.Anchor>

---@class EllesmereUIDB.Profile
---@field addons EllesmereUIDB.Profile.Addons
---@field specUnlockOverrides EllesmereUIDB.Profile.SpecUnlockOverrides
---@field unlockLayout EllesmereUIDB.Profile.UnlockLayout

---@class EllesmereUIDB
---@field activeProfile string
---@field fctFont string
---@field fctFontPath string
---@field fctFontPathFor string
---@field merchantBulkBuy boolean
---@field shifterTopBarUnlock boolean
---@field clickCast EllesmereUIDB.ClickCast
---@field fonts EllesmereUIDB.Font
---@field profiles table<string, EllesmereUIDB.Profile>
---@field unlockAnchors table<string, EllesmereUIDB.Profile.UnlockLayout.Anchor>

---@class RhythmBoxUnlockModeData
---@field key string
---@field target string
---@field side string
---@field offsetX number
---@field offsetY number
---@field x number
---@field y number
---@field grow string?

---@type RhythmBoxUnlockModeData[]
local unlockModeDatas = {
    {
        key = 'EUI_TopBarEventText',
        target = 'TOP',
        side = 'BOTTOM',
        offsetX = 0,
        offsetY = -120,
        x = 0,
        y = 570,
    },
    {
        key = 'MainBar',
        target = 'BOTTOM',
        side = 'TOP',
        offsetX = 0,
        offsetY = 1,
        x = 0,
        y = -701,
        grow = 'center',
    },
    {
        key = 'Bar2',
        target = 'BOTTOM',
        side = 'TOP',
        offsetX = 333,
        offsetY = 1,
        x = 333,
        y = -683,
        grow = 'center',
    },
    {
        key = 'Bar3',
        target = 'BOTTOM',
        side = 'TOP',
        offsetX = 0,
        offsetY = 38,
        x = 0,
        y = -664,
        grow = 'center',
    },
    {
        key = 'Bar4',
        target = 'BOTTOM',
        side = 'TOP',
        offsetX = -333,
        offsetY = 1,
        x = -333,
        y = -683,
        grow = 'center',
    },
    {
        key = 'Bar5',
        target = 'RIGHT',
        side = 'LEFT',
        offsetX = 0,
        offsetY = 0,
        x = 1262,
        y = 0,
        grow = 'center',
    },
    {
        key = 'Bar6',
        target = 'BOTTOM',
        side = 'TOP',
        offsetX = 0,
        offsetY = 112,
        x = 0,
        y = -590,
        grow = 'center',
    },
    {
        key = 'PetBar',
        target = 'BOTTOM',
        side = 'TOP',
        offsetX = 0,
        offsetY = 75,
        x = 0,
        y = -627,
        grow = 'center',
    },
    {
        key = 'StanceBar',
        target = 'LEFT',
        side = 'RIGHT',
        offsetX = 837,
        offsetY = -627,
        x = -333,
        y = -627,
        grow = 'right',
    },
}

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

---@diagnostic disable-next-line: unused-function
function Module:TweakEUIProfile()
    ---@type EllesmereUI
    local EUI = self.EUI

    ---@type EllesmereUIDB
    ---@diagnostic disable-next-line: undefined-field
    local DB = _G.EllesmereUIDB

    local activeProfile = DB.activeProfile
    if activeProfile ~= 'Naowh' then return end

    local Profile = DB.profiles[activeProfile]

    DB.merchantBulkBuy = true
    DB.shifterTopBarUnlock = true
    DB.fctFont = 'smf:GothamNarrowUltra'
    DB.fctFontPath = [[Interface\Addons\RhythmBox\Media\Font\GothamNarrowUltra_Round.ttf]]
    DB.fctFontPathFor = 'smf:GothamNarrowUltra'
    DB.fonts.unitNameFontPath = [[Interface\Addons\RhythmBox\Media\Font\Rhythm.ttf]]

    DB.clickCast.enabled = true
    if DB.clickCast.globals[3].type == 'dispel' then
        DB.clickCast.globals[3].enabled = true
        DB.clickCast.globals[3].smartRez = true
        DB.clickCast.globals[3].oocOnly = false
        DB.clickCast.globals[3].key = 'CTRL-BUTTON1'
    end

    for _, data in ipairs(unlockModeDatas) do
        if data.grow then
            -- XXX: element that has grow is action bar, change this condition when needed
            -- normalize action bar config
            Profile.addons.EllesmereUIActionBars.bars[data.key]._savedBarAlpha = nil
            Profile.addons.EllesmereUIActionBars.bars[data.key].alwaysHidden = false
            Profile.addons.EllesmereUIActionBars.bars[data.key].alwaysShowButtons = true
            Profile.addons.EllesmereUIActionBars.bars[data.key].barVisibility = 'always'
            Profile.addons.EllesmereUIActionBars.bars[data.key].buttonHeight = 36
            Profile.addons.EllesmereUIActionBars.bars[data.key].buttonWidth = 36
            Profile.addons.EllesmereUIActionBars.bars[data.key].combatHideEnabled = false
            Profile.addons.EllesmereUIActionBars.bars[data.key].combatShowEnabled = false
            Profile.addons.EllesmereUIActionBars.bars[data.key].growDirection = data.grow
            Profile.addons.EllesmereUIActionBars.bars[data.key].mouseoverAlpha = 1
            Profile.addons.EllesmereUIActionBars.bars[data.key].mouseoverEnabled = false
            Profile.addons.EllesmereUIActionBars.bars[data.key].orientation = nil
            Profile.addons.EllesmereUIActionBars.bars[data.key].overrideNumRows = 1
            Profile.addons.EllesmereUIActionBars.bars[data.key]._matchExtraPixels = nil
        end
    end

    Profile.addons.EllesmereUIActionBars.bars['Bar2'].overrideNumRows = 2
    Profile.addons.EllesmereUIActionBars.bars['Bar4'].overrideNumRows = 2
    Profile.addons.EllesmereUIActionBars.bars['Bar5'].alwaysShowButtons = false
    Profile.addons.EllesmereUIActionBars.bars['Bar5'].orientation = 'vertical'
    Profile.addons.EllesmereUIActionBars.bars['Bar6'].alwaysShowButtons = false

    Profile.addons.EllesmereUIBags.bagDisplayBindType = true
    Profile.addons.EllesmereUIBags.bagWindowLocked = true
    Profile.addons.EllesmereUIBags.bankWindowLocked = true
    Profile.addons.EllesmereUIChat.chat.persistChatHistory = false
    Profile.addons.EllesmereUIChat.chat.timestampAll = true
    Profile.addons.EllesmereUIChat.chat.timestampFormat = '%H:%M:%S '
    Profile.addons.EllesmereUIDamageMeters.dm.spellHistory.iconEnabled = false

    -- TODO: 锁定背包&银行 背包大小

    for _, data in ipairs(unlockModeDatas) do
        DB.unlockAnchors[data.key].side = data.side
        DB.unlockAnchors[data.key].target = 'SCREEN_' .. data.target
        DB.unlockAnchors[data.key].offsetX = data.offsetX
        DB.unlockAnchors[data.key].offsetY = data.offsetY

        Profile.unlockLayout.anchors[data.key].side = data.side
        Profile.unlockLayout.anchors[data.key].target = 'SCREEN_' .. data.target
        Profile.unlockLayout.anchors[data.key].offsetX = data.offsetX
        Profile.unlockLayout.anchors[data.key].offsetY = data.offsetY

        if Profile.addons.EllesmereUIActionBars.barPositions[data.key] then
            Profile.addons.EllesmereUIActionBars.barPositions[data.key].x = data.x
            Profile.addons.EllesmereUIActionBars.barPositions[data.key].y = data.y
        end

        if Profile.specUnlockOverrides.baselineLayout.anchors[data.key] then
            Profile.specUnlockOverrides.baselineLayout.anchors[data.key].side = data.side
            Profile.specUnlockOverrides.baselineLayout.anchors[data.key].target = 'SCREEN_' .. data.target
            Profile.specUnlockOverrides.baselineLayout.anchors[data.key].offsetX = data.offsetX
            Profile.specUnlockOverrides.baselineLayout.anchors[data.key].offsetY = data.offsetY
        end

        if Profile.specUnlockOverrides.baselineLayout.abPos[data.key] then
            Profile.specUnlockOverrides.baselineLayout.abPos[data.key].x = data.x
            Profile.specUnlockOverrides.baselineLayout.abPos[data.key].y = data.y
        end

        if Profile.specUnlockOverrides.baselineLayout.elems[data.key] then
            Profile.specUnlockOverrides.baselineLayout.elems[data.key].x = data.x
            Profile.specUnlockOverrides.baselineLayout.elems[data.key].y = data.y
        end

        if data.grow and Profile.specUnlockOverrides.baselineLayout.abGrow[data.key] then
            Profile.specUnlockOverrides.baselineLayout.abGrow[data.key] = data.grow
        end

        for _, layout in pairs(Profile.specUnlockOverrides.layouts) do
            if layout.anchors[data.key] then
                layout.anchors[data.key].side = data.side
                layout.anchors[data.key].target = 'SCREEN_' .. data.target
                layout.anchors[data.key].offsetX = data.offsetX
                layout.anchors[data.key].offsetY = data.offsetY
            end

            if layout.abPos[data.key] then
                layout.abPos[data.key].x = data.x
                layout.abPos[data.key].y = data.y
            end

            if data.grow and layout.abGrow[data.key] then
                layout.abGrow[data.key] = data.grow
            end
        end
    end

    EUI.ReapplyAllUnlockAnchorsForced()

    for _, data in ipairs(unlockModeDatas) do
        EUI.SaveBarPosition(data.key, data.side, data.target, data.offsetX, data.offsetY)
    end

    EUI.RefreshAllAddons()
end

function Module:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

function Module:OnEnable()
    self:RawHook(self.SE, 'Blizzard_CooldownViewer')
    self:SecureHook(self.EUI, 'ApplyProfileData', 'TweakEUIProfile')

    self:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED', 'UpdateEditMode')
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'UpdateEditMode')

    LoadEditModeLayout(C_EditMode_GetLayouts())
end

function Module:OnAddonLoad()
    ---@type AceAddon-3.0
    ---@diagnostic disable-next-line: undefined-field
    self.SE = (_G.NaowhUI)[1]:GetModule('Setup')

    ---@type EllesmereUI
    ---@diagnostic disable-next-line: undefined-field
    self.EUI = _G.EllesmereUI
end
