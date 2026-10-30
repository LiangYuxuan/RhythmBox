local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxEasyDeleteConfirm: AceAddon-3.0 & AceEvent-3.0
local EDC = R:NewModule('EasyDeleteConfirm', 'AceEvent-3.0')

---@type RhythmBoxMiscModule
local M = R:GetModule('Misc')
M:Register(EDC, "自动填入DELETE")

-- Lua functions
local _G = _G
local select = select

-- WoW API / Variables
local GetCursorInfo = GetCursorInfo

local StaticPopup_FindVisible = StaticPopup_FindVisible

function EDC:DELETE_ITEM_CONFIRM()
    ---@type StaticPopup1 | StaticPopup2
    local dialog = StaticPopup_FindVisible('DELETE_GOOD_ITEM') or StaticPopup_FindVisible('DELETE_GOOD_QUEST_ITEM')
    if not dialog or not dialog.deleteItemLink then return end

    ---@type EditBox
    local editBox = dialog:GetEditBox()
    if editBox:IsShown() then
        editBox:Hide()
        dialog:GetButton1():Enable()

        local itemLink = select(3, GetCursorInfo())
        dialog.deleteItemLink:SetText(itemLink)
        dialog.deleteItemLink:Show()
    end
end

function EDC:OnDisable()
    self:UnregisterAllEvents()

    local dialog = _G.StaticPopup1
    dialog.deleteItemLink:Hide()
end

function EDC:OnEnable()
    self:RegisterEvent('DELETE_ITEM_CONFIRM')
end

function EDC:OnInitialize()
    local dialog = _G.StaticPopup1

    local deleteItemLink = dialog:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    deleteItemLink:ClearAllPoints()
    deleteItemLink:SetPoint('CENTER', dialog:GetEditBox())
    deleteItemLink:Hide()
    dialog.deleteItemLink = deleteItemLink

    dialog:HookScript('OnHide', function(frame)
        frame.deleteItemLink:Hide()
    end)
end
