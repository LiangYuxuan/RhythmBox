local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxAutoButton: AceAddon-3.0 & AceEvent-3.0
local AB = R:NewModule('AutoButton', 'AceEvent-3.0')

-- Lua functions
local _G = _G
local gsub, ipairs, pairs, select = gsub, ipairs, pairs, select
local table_insert = table.insert
local table_sort = table.sort
local table_wipe = table.wipe

-- WoW API / Variables
local C_Item_GetItemCooldown = C_Item.GetItemCooldown
local C_Item_GetItemCount = C_Item.GetItemCount
local C_Item_GetItemIconByID = C_Item.GetItemIconByID
local C_Item_GetItemInfoInstant = C_Item.GetItemInfoInstant
local C_Item_GetItemQualityByID = C_Item.GetItemQualityByID
local C_Item_GetItemQualityColor = C_Item.GetItemQualityColor
local C_Item_GetItemSpell = C_Item.GetItemSpell
local C_Item_IsItemInRange = C_Item.IsItemInRange
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex
local C_QuestLog_IsComplete = C_QuestLog.IsComplete
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_TradeSkillUI_GetItemReagentQualityInfo = C_TradeSkillUI.GetItemReagentQualityInfo
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetQuestLogSpecialItemCooldown = GetQuestLogSpecialItemCooldown
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local InCombatLockdown = InCombatLockdown
local UnitCanAttack = UnitCanAttack

local tContains = tContains

---@class AutoButton: Button & SecureActionButtonTemplate & BackdropTemplate
---@field icon Texture
---@field qualityOverlay Texture
---@field count FontString
---@field bind FontString
---@field cooldown Cooldown & CooldownFrameTemplate
---@field itemID number
---@field slotID number?
---@field questLogIndex number?

---@class AutoButtonCondition
---@field isReady boolean?
---@field instanceType string[]?
---@field difficultyID number[]?
---@field lessThanLevel number?
---@field maxLevel number?

---@class AutoButtonItemListEntry
---@field itemID number
---@field condition AutoButtonCondition?

---@class AutoButtonItemList
---@field condition AutoButtonCondition?
---@field priority number?
---@field entries AutoButtonItemListEntry[]

---@type table<string, AutoButtonItemList>
local smartItemLists = {
    ['Repair'] = {
        entries = {
            { itemID = 49040,  condition = { isReady = true } }, -- Jeeves
            { itemID = 144341, condition = { isReady = true } }, -- Rechargeable Reaves Battery
            { itemID = 132514, condition = { instanceType = { 'party', 'raid' } } }, -- Auto-Hammer
        },
    },
    ['Glider Kit'] = {
        condition = { instanceType = { 'none', 'pvp' }, difficultyID = { 167 } },
        entries = {
            { itemID = 167861 }, -- Alliance Glider Kit
            { itemID = 167862 }, -- Horde Glider Kit
            { itemID = 109076 }, -- Goblin Glider Kit
        },
    },
    ['Drum'] = {
        condition = { instanceType = { 'party', 'raid' } },
        entries = {
            { itemID = 164978, condition = { maxLevel = 50 } }, -- Mallet of Thunderous Skins
            ---AUTO_GENERATED LEADING AutoButtonSmartDrum
            { itemID = 244639 }, -- Void-Touched Drums
            { itemID = 219905 }, -- Thunderous Drums
            { itemID = 193470, condition = { maxLevel = 70 } }, -- Feral Hide Drums
            { itemID = 172233, condition = { maxLevel = 60 } }, -- Drums of Deathly Ferocity
            { itemID = 154167, condition = { maxLevel = 50 } }, -- Drums of the Maelstrom
            { itemID = 142406, condition = { maxLevel = 50 } }, -- Drums of the Mountain
            { itemID = 120257, condition = { maxLevel = 50 } }, -- Drums of Fury
            { itemID = 102351, condition = { maxLevel = 50 } }, -- Drums of Rage
            ---AUTO_GENERATED TAILING AutoButtonSmartDrum
        },
    },
    ['Flask'] = {
        priority = 2,
        entries = {
            { itemID = 147707 }, -- Repurposed Fel Focuser
        },
    },
    ['Rune'] = {
        entries = {
            ---AUTO_GENERATED LEADING AutoButtonSmartRune
            { itemID = 243191 }, -- Ethereal Augment Rune
            { itemID = 211495 }, -- Dreambound Augment Rune
            { itemID = 190384, condition = { lessThanLevel = 70 } }, -- Eternal Augment Rune
            { itemID = 174906, condition = { lessThanLevel = 60 } }, -- Lightning-Forged Augment Rune
            { itemID = 153023, condition = { lessThanLevel = 50 } }, -- Lightforged Augment Rune
            ---AUTO_GENERATED TAILING AutoButtonSmartRune
        },
    },
    ['Invisibility Potion'] = {
        condition = { instanceType = { 'party' } },
        entries = {
            ---AUTO_GENERATED LEADING AutoButtonSmartInvisibilityPotions
            { itemID = 241302 }, -- Void-Shrouded Tincture (Tier 2)
            { itemID = 241303 }, -- Void-Shrouded Tincture (Tier 1)
            { itemID = 212250 }, -- Draught of Silent Footfalls (Tier 3)
            { itemID = 212249 }, -- Draught of Silent Footfalls (Tier 2)
            { itemID = 212248 }, -- Draught of Silent Footfalls (Tier 1)
            { itemID = 191395 }, -- Potion of the Hushed Zephyr (Tier 3)
            { itemID = 191394 }, -- Potion of the Hushed Zephyr (Tier 2)
            { itemID = 191393 }, -- Potion of the Hushed Zephyr (Tier 1)
            { itemID = 171266, condition = { maxLevel = 60 } }, -- Potion of the Hidden Spirit
            { itemID = 152496, condition = { maxLevel = 50 } }, -- Demitri's Draught of Deception
            { itemID = 127840, condition = { maxLevel = 50 } }, -- Skaggldrynk
            { itemID = 116268, condition = { maxLevel = 50 } }, -- Draenic Invisibility Potion
            { itemID = 9172,   condition = { maxLevel = 50 } }, -- Invisibility Potion
            { itemID = 3823,   condition = { maxLevel = 50 } }, -- Lesser Invisibility Potion
            ---AUTO_GENERATED TAILING AutoButtonSmartInvisibilityPotions
        },
    },
}

---@type table<number, number>
local normalItemLists = {
    -- Shadowlands
    [184652] = 6, -- Phantasmic Infuser
    [168207] = 5, -- Plundered Anima Cell
    [184662] = 5, -- Requisitioned Anima Cell
    [185946] = 4, -- Long Tail Dynarats
    [170540] = 3, -- Ravenous Anima Cell
    [176443] = 3, -- Fleeting Frenzy Potion
}

---@type table<number, boolean>
local slotBlackList = {
    -- Don't use
    [169064] = true, -- Mountebank's Colorful Cloak
    [186410] = true, -- Jaithys, the Prison Blade
    [193000] = true, -- Ring-Bound Hourglass

    -- Ignore for shorter length
    -- General
    [52252]  = true, -- Tabard of the Lightbringer
    [63379]  = true, -- Baradin's Wardens Tabard
    [89196]  = true, -- Theramore Tabard
}

-- change Bindings.xml when changing these
local maxButton = 12
local autoSlotButtonName = "自动装备物品"
local autoQuestButtonName = "自动任务物品"

---@param self AutoButton
local function ButtonOnEnter(self)
    _G.GameTooltip:Hide()
    _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, -2)
    _G.GameTooltip:ClearLines()

    if self.slotID then
        _G.GameTooltip:SetInventoryItem('player', self.slotID)
    else
        _G.GameTooltip:SetItemByID(self.itemID)
    end

    _G.GameTooltip:Show()
end

---@param self AutoButton
local function ButtonOnLeave(self)
    _G.GameTooltip:Hide()
end

---@param self AutoButton
local function ButtonOnUpdate(self)
    ---@type number, number, number | boolean
    local startTime, duration, enable
    if self.questLogIndex then
        startTime, duration, enable = GetQuestLogSpecialItemCooldown(self.questLogIndex)
    elseif self.slotID then
        startTime, duration, enable = GetInventoryItemCooldown('player', self.slotID)
    else
        startTime, duration, enable = C_Item_GetItemCooldown(self.itemID)
    end

    if enable and enable ~= 0 and startTime > 0 and duration > 0 then
        self.cooldown:SetCooldown(startTime, duration)
    else
        self.cooldown:Clear()
    end

    if (enable == false or enable == 0) and duration > 0 then
        self.icon:SetVertexColor(0.4, 0.4, 0.4)
    elseif (
        not self.slotID and
        (not InCombatLockdown() or UnitCanAttack('player', 'target')) and
        C_Item_IsItemInRange(self.itemID, 'target') == false
    ) then
        self.icon:SetVertexColor(0.8, 0.1, 0.1)
    else
        self.icon:SetVertexColor(1, 1, 1)
    end
end

do
    ---@type number[]
    local itemList = {}

    ---@type table<number, number>
    local itemPriorityList = {}

    ---@param left number
    ---@param right number
    ---@return boolean
    local function compare(left, right)
        if itemPriorityList[left] ~= itemPriorityList[right] then
            return itemPriorityList[left] > itemPriorityList[right]
        end

        local leftSubClassID = select(7, C_Item_GetItemInfoInstant(left))
        local rightSubClassID = select(7, C_Item_GetItemInfoInstant(right))
        if leftSubClassID ~= rightSubClassID then
            return leftSubClassID > rightSubClassID
        end

        return left > right
    end

    ---@param condition AutoButtonCondition
    ---@param itemID number?
    ---@return boolean
    local function checkCondition(condition, itemID)
        if condition.isReady and itemID then
            local _, duration, enable = C_Item_GetItemCooldown(itemID)
            if duration == 0 and enable then
                return true
            end
        end

        if condition.instanceType then
            if tContains(condition.instanceType, R.playerInstanceType) then
                return true
            end
        end

        if condition.difficultyID then
            if tContains(condition.difficultyID, R.playerInstanceDifficultyID) then
                return true
            end
        end

        if condition.lessThanLevel then
            if R.playerLevel < condition.lessThanLevel then
                return true
            end
        end

        if condition.maxLevel then
            if R.playerLevel <= condition.maxLevel then
                return true
            end
        end

        return false
    end

    ---@return number[]
    function AB:BuildItemList()
        table_wipe(itemList)
        table_wipe(itemPriorityList)

        for itemID, priority in pairs(normalItemLists) do
            local count = C_Item_GetItemCount(itemID)
            if count > 0 then
                table_insert(itemList, itemID)
                itemPriorityList[itemID] = priority
            end
        end

        for _, smartItemList in pairs(smartItemLists) do
            if not smartItemList.condition or checkCondition(smartItemList.condition) then
                ---@type number?
                local itemID
                for _, entry in ipairs(smartItemList.entries) do
                    local count = C_Item_GetItemCount(entry.itemID)
                    if count > 0 and (not entry.condition or checkCondition(entry.condition, entry.itemID)) then
                        itemID = entry.itemID
                        break
                    end
                end

                if itemID then
                    table_insert(itemList, itemID)
                    itemPriorityList[itemID] = smartItemList.priority or 1
                end
            end
        end

        table_sort(itemList, compare)

        return itemList
    end
end

---@param button AutoButton
---@param itemID number
---@param questLogIndex number?
---@param itemIcon number?
function AB:SetupQuestButton(button, itemID, questLogIndex, itemIcon)
    button.itemID = itemID
    button.questLogIndex = questLogIndex

    button:SetAttribute('*type1', 'item')
    button:SetAttribute('*item1', 'item:' .. itemID)

    if not itemIcon then
       itemIcon = C_Item_GetItemIconByID(itemID)
    end

    local count = C_Item_GetItemCount(itemID, nil, true)
    local rarity = C_Item_GetItemQualityByID(itemID)
    local r, g, b = C_Item_GetItemQualityColor((rarity and rarity > 1 and rarity) or 1)
    local info = C_TradeSkillUI_GetItemReagentQualityInfo(itemID)

    if count > 1 then
        ---@diagnostic disable-next-line: type-mismatch
        button.count:SetText(count)
    else
        button.count:SetText("")
    end

    button.icon:SetTexture(itemIcon)
    button:SetBackdropBorderColor(r, g, b)
    if info then
        button.qualityOverlay:SetAtlas(info.iconInventory, true)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        button.qualityOverlay:SetAtlas(nil)
    end
end

function AB:UpdateQuestBar()
    if InCombatLockdown() then
        self:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateAllButtons')
        return
    end

    local index = 1

    local numShownEntries = C_QuestLog_GetNumQuestLogEntries()
    for questLogIndex = 1, numShownEntries do
        local questID = C_QuestLog_GetQuestIDForLogIndex(questLogIndex)
        if questID and C_QuestLog_IsWorldQuest(questID) then
            local itemLink, itemIcon = GetQuestLogSpecialItemInfo(questLogIndex)
            if itemLink then
                local itemID = C_Item_GetItemInfoInstant(itemLink)

                local button = self.questButtons[index]
                self:SetupQuestButton(button, itemID, questLogIndex, itemIcon)
                button:Show()

                index = index + 1
                if index > maxButton then
                    return
                end
            end
        end
    end

    local numQuestWatches = C_QuestLog_GetNumQuestWatches()
    for questWatchIndex = 1, numQuestWatches do
        local questID = C_QuestLog_GetQuestIDForQuestWatchIndex(questWatchIndex)
        local questLogIndex = questID and C_QuestLog_GetLogIndexForQuestID(questID)
        if questLogIndex then
            local isComplete = C_QuestLog_IsComplete(questID)
            local itemLink, itemIcon, _, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
            if itemLink and (showItemWhenComplete or not isComplete) then
                local itemID = C_Item_GetItemInfoInstant(itemLink)

                local button = self.questButtons[index]
                self:SetupQuestButton(button, itemID, questLogIndex, itemIcon)
                button:Show()

                index = index + 1
                if index > maxButton then
                    return
                end
            end
        end
    end

    local itemList = self:BuildItemList()
    for _, itemID in ipairs(itemList) do
        local button = self.questButtons[index]
        self:SetupQuestButton(button, itemID)
        button:Show()

        index = index + 1
        if index > maxButton then
            return
        end
    end

    for i = index, maxButton do
        local button = self.questButtons[i]
        if button then
            button:Hide()
        end
    end
end

---@param event string?
---@param unitID string?
function AB:UpdateSlotBar(event, unitID)
    if event == 'UNIT_INVENTORY_CHANGED' and unitID ~= 'player' then return end

    if InCombatLockdown() then
        self:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateAllButtons')
        return
    end

    local index = 1

    for slotID = 1, 19 do
        local itemID = GetInventoryItemID('player', slotID)
        ---@diagnostic disable-next-line: redundant-and
        if itemID and not slotBlackList[itemID] then
            local _, spellID = C_Item_GetItemSpell(itemID)
            if spellID then
                local rarity = GetInventoryItemQuality('player', slotID)
                local itemIcon = GetInventoryItemTexture('player', slotID)
                ---@diagnostic disable-next-line: redundant-and
                local r, g, b = C_Item_GetItemQualityColor((rarity and rarity > 1 and rarity) or 1)

                local button = self.slotButtons[index]
                button.itemID = itemID
                button.slotID = slotID
                button:SetAttribute('*type1', 'item')
                button:SetAttribute('*item1', slotID)

                button:SetBackdropBorderColor(r, g, b)
                button.icon:SetTexture(itemIcon)
                button:Show()

                index = index + 1
                if index > maxButton then
                    return
                end
            end
        end
    end

    for i = index, maxButton do
        local button = self.slotButtons[i]
        if button then
            button:Hide()
        end
    end
end

function AB:UpdateAllButtons()
    self:UpdateSlotBar()
    self:UpdateQuestBar()
end

function AB:UpdateButtonsBinding()
    for buttonIndex, button in ipairs(self.slotButtons) do
        local bindButton = 'CLICK RhythmBoxABSlot' .. buttonIndex .. ':LeftButton'
        local bindText = GetBindingKey(bindButton)

        if not bindText then
            bindText = ''
        else
            bindText = gsub(bindText, 'SHIFT--', 'S')
            bindText = gsub(bindText, 'CTRL--', 'C')
            bindText = gsub(bindText, 'ALT--', 'A')
        end

        button.bind:SetText(bindText)
    end

    for buttonIndex, button in ipairs(self.questButtons) do
        local bindButton = 'CLICK RhythmBoxABQuest' .. buttonIndex .. ':LeftButton'
        local bindText = GetBindingKey(bindButton)

        if not bindText then
            bindText = ''
        else
            bindText = gsub(bindText, 'SHIFT--', 'S')
            bindText = gsub(bindText, 'CTRL--', 'C')
            bindText = gsub(bindText, 'ALT--', 'A')
        end

        button.bind:SetText(bindText)
    end
end

function AB:UpdateLayout()
    self.slotContainer:ClearAllPoints()
    self.slotContainer:SetPoint('LEFT', _G.UIParent, 'CENTER', R.db.AutoButton.SlotPositionX, R.db.AutoButton.SlotPositionY)
    self.slotContainer:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)

    self.questContainer:ClearAllPoints()
    self.questContainer:SetPoint('LEFT', _G.UIParent, 'CENTER', R.db.AutoButton.QuestPositionX, R.db.AutoButton.QuestPositionY)
    self.questContainer:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)

    for i, button in ipairs(self.slotButtons) do
        button:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)
        R:SetupFont(button.count, R.db.AutoButton.CountFontSize)
        R:SetupFont(button.bind, R.db.AutoButton.BindFontSize)
    end

    for i, button in ipairs(self.questButtons) do
        button:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)
        R:SetupFont(button.count, R.db.AutoButton.CountFontSize)
        R:SetupFont(button.bind, R.db.AutoButton.BindFontSize)
    end
end

---@param buttonType string
---@param buttonIndex number
---@param parent Frame
---@return AutoButton
function AB:CreateButton(buttonType, buttonIndex, parent)
    ---@type AutoButton
    local button = CreateFrame('Button', 'RhythmBoxAB' .. buttonType .. buttonIndex, parent, 'SecureActionButtonTemplate, BackdropTemplate')

    button:SetScript('OnEnter', ButtonOnEnter)
    button:SetScript('OnLeave', ButtonOnLeave)
    button:SetScript('OnUpdate', ButtonOnUpdate)

    button:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)
    button:EnableMouse(true)
    button:RegisterForClicks('AnyUp', 'AnyDown')
    R:SetupBackdrop(button)
    R:SetupButtonHighlight(button)
    R:RegisterNonPetBattleFrame(button, parent)

    button.icon = button:CreateTexture(nil, 'OVERLAY')
    R:SetupIcon(button.icon, button)

    button.qualityOverlay = button:CreateTexture(nil, 'OVERLAY')
    button.qualityOverlay:SetPoint("TOPLEFT", -3, 2)

    button.count = button:CreateFontString(nil, 'OVERLAY')
    button.count:SetTextColor(1, 1, 1, 1)
    button.count:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 0.5 ,0)
    button.count:SetJustifyH('CENTER')
    R:SetupFont(button.count, R.db.AutoButton.CountFontSize)

    button.bind = button:CreateFontString(nil, 'OVERLAY')
    button.bind:SetTextColor(0.6, 0.6, 0.6)
    button.bind:SetPoint('TOPRIGHT', button, 'TOPRIGHT', 1 ,-3)
    button.bind:SetJustifyH('RIGHT')
    R:SetupFont(button.bind, R.db.AutoButton.BindFontSize)

    button.cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
    R:SetupCooldown(button.cooldown, button)

    return button
end

function AB:OnDisable()
    self.slotContainer:Hide()
    self.questContainer:Hide()

    self:UnregisterAllEvents()
end

function AB:OnEnable()
    self.slotContainer:Show()
    self.questContainer:Show()

    self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'UpdateSlotBar')
    self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateSlotBar')

    self:RegisterEvent('QUEST_LOG_UPDATE', 'UpdateQuestBar')
    self:RegisterEvent('QUEST_WATCH_LIST_CHANGED', 'UpdateQuestBar')
    self:RegisterEvent('QUEST_ACCEPTED', 'UpdateQuestBar')
    self:RegisterEvent('QUEST_TURNED_IN', 'UpdateQuestBar')

    self:RegisterEvent('BAG_UPDATE_DELAYED', 'UpdateQuestBar')
    self:RegisterEvent('BAG_UPDATE_COOLDOWN', 'UpdateQuestBar')
    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateQuestBar')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'UpdateQuestBar')

    self:RegisterEvent('UPDATE_BINDINGS', 'UpdateButtonsBinding')

    self:UpdateAllButtons()
    self:UpdateButtonsBinding()
end

_G['BINDING_HEADER_RhythmBoxAutoSlotButton'] = "Rhythm Box " .. autoSlotButtonName
_G['BINDING_HEADER_RhythmBoxAutoQuestButton'] = "Rhythm Box " .. autoQuestButtonName
for i = 1, maxButton do
    _G['BINDING_NAME_CLICK RhythmBoxABSlot' .. i .. ':LeftButton'] = autoSlotButtonName .. i
    _G['BINDING_NAME_CLICK RhythmBoxABQuest' .. i .. ':LeftButton'] = autoQuestButtonName .. i
end

---@class RhythmBoxProfile
local P = Engine.Profile
---@class RhythmBoxAutoButtonProfile
P.AutoButton = {
    Enable = true,
    SlotPositionX = 450,
    SlotPositionY = -462,
    QuestPositionX = 450,
    QuestPositionY = -506,
    ButtonSize = 40,
    BindFontSize = 18,
    CountFontSize = 18,
}

R:RegisterOptions(
    AB,
    "自动物品动作条",
    ---@param optionName string?
    function(optionName)
        AB:UpdateLayout()
    end,
    ---@param options AceConfig.OptionsTable
    function(options)
        options.args = {
            Enable = {
                order = 1,
                type = 'toggle',
                name = "启用",
            },
            Space1 = {
                order = 10,
                type = 'description',
                name = "",
                width = 'full',
            },
            SlotPositionX = {
                order = 11,
                type = 'range',
                name = "装备条水平位置",
                min = -2048, max = 2048, step = 1,
            },
            SlotPositionY = {
                order = 12,
                type = 'range',
                name = "装备条垂直位置",
                min = -2048, max = 2048, step = 1,
            },
            Space2 = {
                order = 20,
                type = 'description',
                name = "",
                width = 'full',
            },
            QuestPositionX = {
                order = 21,
                type = 'range',
                name = "任务条水平位置",
                min = -2048, max = 2048, step = 1,
            },
            QuestPositionY = {
                order = 22,
                type = 'range',
                name = "任务条垂直位置",
                min = -2048, max = 2048, step = 1,
            },
            Space3 = {
                order = 30,
                type = 'description',
                name = "",
                width = 'full',
            },
            ButtonSize = {
                order = 31,
                type = 'range',
                name = "按钮尺寸",
                min = 10, max = 100, step = 1,
            },
            BindFontSize = {
                order = 32,
                type = 'range',
                min = 4, max = 40, step = 1,
                name = "键位文字字体尺寸",
            },
            CountFontSize = {
                order = 33,
                type = 'range',
                min = 4, max = 40, step = 1,
                name = "物品数量字体尺寸",
            },
        }
    end
)

function AB:OnInitialize()
    ---@type AutoButton[]
    self.slotButtons = {}
    ---@type AutoButton[]
    self.questButtons = {}

    local slotContainer = CreateFrame('Frame', 'RhythmBoxAutoButtonSlotContainer', _G.UIParent)
    slotContainer:ClearAllPoints()
    slotContainer:SetPoint('LEFT', _G.UIParent, 'CENTER', R.db.AutoButton.SlotPositionX, R.db.AutoButton.SlotPositionY)
    slotContainer:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)
    self.slotContainer = slotContainer

    local questContainer = CreateFrame('Frame', 'RhythmBoxAutoButtonQuestContainer', _G.UIParent)
    questContainer:ClearAllPoints()
    questContainer:SetPoint('LEFT', _G.UIParent, 'CENTER', R.db.AutoButton.QuestPositionX, R.db.AutoButton.QuestPositionY)
    questContainer:SetSize(R.db.AutoButton.ButtonSize, R.db.AutoButton.ButtonSize)
    self.questContainer = questContainer

    for i = 1, maxButton do
        local slotButton = self:CreateButton('Slot', i, slotContainer)
        table_insert(self.slotButtons, slotButton)

        local questButton = self:CreateButton('Quest', i, questContainer)
        table_insert(self.questButtons, questButton)

        if i == 1 then
            slotButton:ClearAllPoints()
            slotButton:SetPoint('LEFT', slotContainer)

            questButton:ClearAllPoints()
            questButton:SetPoint('LEFT', questContainer)
        else
            slotButton:ClearAllPoints()
            slotButton:SetPoint('LEFT', self.slotButtons[i - 1], 'RIGHT', 3, 0)

            questButton:ClearAllPoints()
            questButton:SetPoint('LEFT', self.questButtons[i - 1], 'RIGHT', 3, 0)
        end
    end
end
