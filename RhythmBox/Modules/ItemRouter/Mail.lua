local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxItemRouterMail: AceAddon-3.0 & AceEvent-3.0 & AceHook-3.0
local IRM = R:NewModule('ItemRouterMail', 'AceEvent-3.0', 'AceHook-3.0')
---@type RhythmBoxItemRouter
local IR = R:GetModule('ItemRouter')

-- Lua functions
local _G = _G
local math_floor = math.floor
local math_fmod = math.fmod
local string_format = string.format
local string_match = string.match
local table_remove = table.remove

-- WoW API / Variables
local CreateFrame = CreateFrame

local MenuUtil_CreateContextMenu = MenuUtil.CreateContextMenu
local MoneyInputFrame_GetCopper = MoneyInputFrame_GetCopper

local goldTemplate = string_format("[%s %s %s]", GOLD_AMOUNT, SILVER_AMOUNT, COPPER_AMOUNT)
local silverTemplate = string_format("[%s %s]", SILVER_AMOUNT, COPPER_AMOUNT)
local copperTemplate = string_format("[%s]", COPPER_AMOUNT)

local goldPattern = '^' .. goldTemplate:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%%d', '%%d+') .. '$'
local silverPattern = '^' .. silverTemplate:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%%d', '%%d+') .. '$'
local copperPattern = '^' .. copperTemplate:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%%d', '%%d+') .. '$'

---@param index number
local function MoveUp(index)
    local characters = R.global.ItemRouter.characters
    if index > 1 then
        characters[index], characters[index - 1] = characters[index - 1], characters[index]
        IRM:UpdateAltFrame()
    end
end

---@param index number
local function MoveDown(index)
    local characters = R.global.ItemRouter.characters
    if index < #characters then
        characters[index], characters[index + 1] = characters[index + 1], characters[index]
        IRM:UpdateAltFrame()
    end
end

---@param index number
local function Delete(index)
    local characters = R.global.ItemRouter.characters
    if index >= 1 and index <= #characters then
        table_remove(R.global.ItemRouter.characters, index)
        IRM:UpdateAltFrame()
    end
end

---@param self RhythmBoxItemRouterMailButton
---@param rootDescription RootMenuDescriptionProxy
local function MenuGenerator(self, rootDescription)
    local buttonMoveUp = rootDescription:CreateButton("上移", MoveUp, self.index)
    buttonMoveUp:SetEnabled(self.index and self.index > 1 or false)

    local buttonMoveDown = rootDescription:CreateButton("下移", MoveDown, self.index)
    buttonMoveDown:SetEnabled(self.index and self.index < #R.global.ItemRouter.characters or false)

    rootDescription:CreateButton("删除", Delete, self.index)
end

---@param self RhythmBoxItemRouterMailButton
---@param button string
local function ButtonOnClick(self, button)
    if not self.characterData then return end

    if button == 'RightButton' then
        MenuUtil_CreateContextMenu(self, MenuGenerator)
        return
    end

    local name = self.characterData.name
    local realm = self.characterData.realm

    local displayName = name .. (realm ~= R.playerRealm and (' - ' .. realm) or '')

    _G.SendMailNameEditBox:SetText(displayName)
end

---@param self RhythmBoxItemRouterMailButton
---@param index number
local function SetupCharacter(self, index)
    local characterData = R.global.ItemRouter.characters[index]

    self.index = index
    self.characterData = characterData

    local name = characterData.name
    local realm = characterData.realm

    local displayName = name .. (realm ~= R.playerRealm and (' - ' .. realm) or '')
    local classColor = R:ClassColor(characterData.class)
    self:SetText(R:WrapTextInColorCode(displayName, classColor))

    self:SetEnabled(characterData ~= IR.characterData)
end

---@diagnostic disable-next-line: unused-function
function IRM:OnMailMoneyChanged()
    local editbox = _G.SendMailSubjectEditBox
    local subject = editbox:GetText()

    if (
        #subject <= 0 or string_match(subject, goldPattern) or
        string_match(subject, silverPattern) or string_match(subject, copperPattern)
    ) then
        local money = MoneyInputFrame_GetCopper(_G.SendMailMoney)
        if money > 0 then
            local gold = math_floor(money / 10000)
            local silver = math_floor((money - gold * 10000) / 100)
            local copper = math_fmod(money, 100)
            if gold > 0 then
                editbox:SetText(string_format(goldTemplate, gold, silver, copper))
            elseif silver > 0 then
                editbox:SetText(string_format(silverTemplate, silver, copper))
            else
                editbox:SetText(string_format(copperTemplate, copper))
            end
        else
            editbox:SetText('')
        end
    end
end

function IRM:UpdateAltFrame()
    local length = #R.global.ItemRouter.characters

    self.altFrame:SetSize(200, 10 + length * 25)

    for i = 1, length do
        self.altFrame.button[i]:SetupCharacter(i)
    end

    for i = length + 1, #self.altFrame.button do
        self.altFrame.button[i]:Hide()
    end
end

---@return RhythmBoxItemRouterMailFrame
function IRM:BuildAltFrame()
    local length = #R.global.ItemRouter.characters

    ---@class RhythmBoxItemRouterMailFrame: Frame & BackdropTemplate
    ---@field button RhythmBoxItemRouterMailButton[]
    local frame = CreateFrame('Frame', nil, _G.SendMailFrame, 'BackdropTemplate')
    frame:SetPoint('TOPLEFT', _G.SendMailFrame, 'TOPRIGHT', -30, 0)
    frame:SetSize(200, 10 + length * 25)
    R:SetupBackdrop(frame)

    ---@type RhythmBoxItemRouterMailButton[]
    frame.button = {}

    for i = 1, length do
        ---@class RhythmBoxItemRouterMailButton: RhythmBoxTextButton
        ---@field index number?
        ---@field characterData RhythmBoxItemRouterCharacterData?
        ---@field SetupCharacter fun(self: RhythmBoxItemRouterMailButton, index: number)
        local button = R:CreateTextButton(frame)
        button:SetPoint('TOP', frame, 'TOP', 0, 19 - i * 25) -- - 5 - 1 - (i - 1) * 25
        button:SetSize(190, 23)
        button:RegisterForClicks('AnyUp')
        button:SetScript('OnClick', ButtonOnClick)

        button.SetupCharacter = SetupCharacter

        frame.button[i] = button

        button:SetupCharacter(i)
    end

    return frame
end

function IRM:OnDisable()
    self.altFrame:Hide()

    self:UnhookAll()
end

function IRM:OnEnable()
    self.altFrame:Show()

    self:SecureHook(_G.SendMailMoney, 'onValueChangedFunc', 'OnMailMoneyChanged')
end

function IRM:OnInitialize()
    self.altFrame = self:BuildAltFrame()
end
