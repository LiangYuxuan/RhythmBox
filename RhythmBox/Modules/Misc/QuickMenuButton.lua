local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxQuickMenuButton: AceAddon-3.0 & AceEvent-3.0
local QMB = R:NewModule('QuickMenuButton', 'AceEvent-3.0')
local LRI = Engine.Libs.LRI

-- Lua functions
local _G = _G
local ipairs, issecretvalue = ipairs, issecretvalue
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local string_split = string.split
local string_sub = string.sub

-- WoW API / Variables
local C_GuildInfo_Invite = C_GuildInfo.Invite
local C_LFGList_GetApplicantMemberInfo = C_LFGList.GetApplicantMemberInfo
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_Timer_After = C_Timer.After
local GetGuildInfo = GetGuildInfo
local IsControlKeyDown = IsControlKeyDown
local UnitNameUnmodified = UnitNameUnmodified

local Menu_ModifyMenu = Menu.ModifyMenu
local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Hide = StaticPopup_Hide

local COPY_NAME = COPY_NAME

local INVITE_TO_GUILD = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, '')

local function CopiedToClipboard()
    StaticPopup_Hide('RHYTHMBOX_COPY_TEXT')
    _G.UIErrorsFrame:AddMessage("已复制到剪贴板")
end

StaticPopupDialogs['RHYTHMBOX_COPY_TEXT'] = {
    text = '%s',
    button2 = CLOSE,
    hasEditBox = true,
    hasWideEditBox = true,
    editBoxWidth = 350,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    ---@param dialog StaticPopupTemplate
    OnShow = function(dialog)
        dialog:SetWidth(420)

        ---@type EditBox
        local editBox = dialog:GetEditBox()
        editBox:SetText(dialog:GetTextFontString().text_arg2)
        editBox:SetFocus()
        editBox:HighlightText()
        ---@param _ EditBox
        ---@param key string
        editBox:SetScript('OnKeyDown', function(_, key)
            if key == 'C' and IsControlKeyDown() then
                C_Timer_After(0.1, CopiedToClipboard)
            end
        end)

        ---@type Button
        local button = dialog:GetButton2()
        button:ClearAllPoints()
        button:SetWidth(200)
        button:SetPoint('CENTER', editBox, 'CENTER', 0, -30)
    end,
    ---@param self EditBox
    EditBoxOnEscapePressed = function(self)
        local parent = self:GetParent()
        if parent then
            parent:Hide()
        end
    end,
    OnHide = nil,
    OnAccept = nil,
    OnCancel = nil,
}

local menuTags = {
    'MENU_UNIT_SELF',
    -- 'MENU_UNIT_PET',
    -- 'MENU_UNIT_OTHERPET',
    -- 'MENU_UNIT_BATTLEPET',
    -- 'MENU_UNIT_OTHERBATTLEPET',
    'MENU_UNIT_PARTY',
    'MENU_UNIT_PLAYER',
    'MENU_UNIT_ENEMY_PLAYER',
    'MENU_UNIT_RAID_PLAYER',
    'MENU_UNIT_RAID',
    'MENU_UNIT_FRIEND',
    'MENU_UNIT_FRIEND_OFFLINE',
    'MENU_UNIT_BN_FRIEND',
    -- 'MENU_UNIT_BN_FRIEND_OFFLINE',
    -- 'MENU_UNIT_GLUE_FRIEND',
    -- 'MENU_UNIT_GLUE_FRIEND_OFFLINE',
    'MENU_UNIT_GUILD',
    'MENU_UNIT_GUILD_OFFLINE',
    'MENU_UNIT_CHAT_ROSTER',
    -- 'MENU_UNIT_VEHICLE',
    'MENU_UNIT_TARGET',
    'MENU_UNIT_ARENAENEMY',
    'MENU_UNIT_FOCUS',
    -- 'MENU_UNIT_BOSS',
    'MENU_UNIT_COMMUNITIES_WOW_MEMBER',
    'MENU_UNIT_COMMUNITIES_GUILD_MEMBER',
    -- 'MENU_UNIT_GUILDS_GUILD',
    -- 'MENU_UNIT_COMMUNITIES_MEMBER',
    -- 'MENU_UNIT_COMMUNITIES_COMMUNITY',
    -- 'MENU_UNIT_RAID_TARGET_ICON',
    'MENU_UNIT_WORLD_STATE_SCORE',
    -- 'MENU_UNIT_PVP_SCOREBOARD',
    -- 'MENU_UNIT_GLUE_PARTY_MEMBER',
}

---@param realmName string
---@return string, string, string
local function GetServerURLInfo(realmName)
    if string_find(realmName, '）') then
        -- LibRealmInfo have corrupted realm name for CN regions like "丽丽（四川）", it stores it as "丽丽（四川)"
        -- so we replace it to make LibRealmInfo happy
        realmName = string_gsub(realmName, '）', ')')
    end

    local _, name, _, _, locale, _, region, _, _, englishName = LRI:GetRealmInfo(realmName)

    local regionURL = string_lower(region)
    local localeURL = string_lower(string_sub(locale, 1, 2) .. '-' .. string_sub(locale, 3, 4))
    local realmNameURL = string_lower(string_gsub(string_gsub(englishName or name, '\'', ''), ' ', '-'))

    return regionURL, localeURL, realmNameURL
end

---@param text string
local function ShowStaticPopupDialog(text)
    StaticPopup_Show('RHYTHMBOX_COPY_TEXT', "按 Ctrl + C 复制", text)
end

---@param rootDescription RootMenuDescriptionProxy
---@param name string
---@param realm string
local function HandleMenu(rootDescription, name, realm)
    local fullName = name .. '-' .. realm

    local isInGuild = GetGuildInfo(realm == R.playerRealm and name or fullName)

    rootDescription:CreateDivider()
    rootDescription:CreateTitle('Rhythm Box')
    rootDescription:CreateButton(COPY_NAME, ShowStaticPopupDialog, fullName)

    local regionURL, localeURL, realmNameURL = GetServerURLInfo(realm)
    local armoryURL
    if LRI:GetCurrentRegion() == 'CN' then
        armoryURL = 'https://wow.blizzard.cn/character/#/' .. realmNameURL .. '/' .. name
    else
        armoryURL = 'https://worldofwarcraft.com/' .. localeURL .. '/character/' .. regionURL .. '/' .. realmNameURL .. '/' .. name
    end
    local wclURL = 'https://' .. regionURL .. '.warcraftlogs.com/character/' .. regionURL .. '/' .. realmNameURL .. '/' .. name
    local rioURL = 'https://raider.io/characters/' .. regionURL .. '/' .. realmNameURL .. '/' .. name

    rootDescription:CreateButton("复制英雄榜地址", ShowStaticPopupDialog, armoryURL)
    rootDescription:CreateButton("复制 Logs 地址", ShowStaticPopupDialog, wclURL)
    rootDescription:CreateButton("复制 RIO 地址", ShowStaticPopupDialog, rioURL)

    ---@diagnostic disable-next-line: redundant-condition
    if not isInGuild then
        rootDescription:CreateButton(INVITE_TO_GUILD, C_GuildInfo_Invite, fullName)
    end
end

---@class UnitMenuContextData
---@field which string
---@field unit string?
---@field name secret<string>?
---@field server secret<string>?
---@field accountInfo BNetAccountInfo?

---@param _ Region
---@param rootDescription RootMenuDescriptionProxy
---@param contextData UnitMenuContextData
local function OnUnitMenuShow(_, rootDescription, contextData)
    if contextData.accountInfo then
        local name = contextData.accountInfo.gameAccountInfo.characterName
        local realm = contextData.accountInfo.gameAccountInfo.realmName

        if name then
            HandleMenu(rootDescription, name, realm or R.playerRealm)
        end
    elseif contextData.unit then
        ---@type secret<string>?, secret<string>?
        local name, realm = UnitNameUnmodified(contextData.unit)

        if name and not issecretvalue(name) then
            HandleMenu(rootDescription, name, realm or R.playerRealm)
        end
    else
        local name = contextData.name
        local realm = contextData.server

        if name and not issecretvalue(name) then
            HandleMenu(rootDescription, name, realm or R.playerRealm)
        end
    end
end

---@param owner LFGListSearchEntryTemplate & { resultID: number }
---@param rootDescription RootMenuDescriptionProxy
local function OnSearchEntryMenuShow(owner, rootDescription)
    local searchResultData = C_LFGList_GetSearchResultInfo(owner.resultID)
    ---@diagnostic disable-next-line: redundant-condition
    if not searchResultData then return end

    local leaderName = searchResultData.leaderName
    if not leaderName then return end

    ---@type string, string?
    local name, realm = string_split('-', leaderName)
    HandleMenu(rootDescription, name, realm or R.playerRealm)
end

---@param owner LFGListApplicantMemberTemplate & { memberIdx: number? }
---@param rootDescription RootMenuDescriptionProxy
local function OnMemberApplyMenuShow(owner, rootDescription)
    ---@type LFGListApplicantTemplate & { applicantID: number? }
    local parent = owner:GetParent()
    local applicantID = parent.applicantID
    local memberIdx = owner.memberIdx
    if not applicantID or not memberIdx then return end

    local memberName = C_LFGList_GetApplicantMemberInfo(applicantID, memberIdx)
    ---@type string, string?
    local name, realm = string_split('-', memberName)
    HandleMenu(rootDescription, name, realm or R.playerRealm)
end

function QMB:OnInitialize()
    -- Load LibRealmInfo Info
    LRI:GetCurrentRegion()

    for _, tag in ipairs(menuTags) do
        Menu_ModifyMenu(tag, OnUnitMenuShow)
    end

    Menu_ModifyMenu('MENU_LFG_FRAME_SEARCH_ENTRY', OnSearchEntryMenuShow)
    Menu_ModifyMenu('MENU_LFG_FRAME_MEMBER_APPLY', OnMemberApplyMenuShow)
end
