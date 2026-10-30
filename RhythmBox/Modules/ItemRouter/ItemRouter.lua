local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxItemRouter: AceAddon-3.0 & AceEvent-3.0
local IR = R:NewModule('ItemRouter', 'AceEvent-3.0')

-- Lua functions
local ipairs = ipairs

-- WoW API / Variables

---@class RhythmBoxItemRouterCharacterData
---@field name string
---@field realm string
---@field faction string
---@field class string
---@field level number

---@class RhythmBoxGlobalProfile
local G = Engine.GlobalProfile
---@class RhythmBoxItemRouterGlobalProfile
---@field characters RhythmBoxItemRouterCharacterData[]
G.ItemRouter = {
    characters = {},
}

function IR:UpdateCharacterData()
end

function IR:UpdateCharacterLevel()
    self.characterData.level = R.playerLevel
end

function IR:OnDisable()
    self:UnregisterAllEvents()
end

function IR:OnEnable()
    self:RegisterEvent('PLAYER_LOGOUT', 'UpdateCharacterLevel')

    self:UpdateCharacterData()
end

function IR:OnInitialize()
    local index = #R.global.ItemRouter.characters + 1
    for i, character in ipairs(R.global.ItemRouter.characters) do
        if character.name == R.playerName and character.realm == R.playerRealm then
            index = i
            break
        end
    end

    R.global.ItemRouter.characters[index] = R.global.ItemRouter.characters[index] or {
        name = R.playerName,
        realm = R.playerRealm,
    }

    self.characterData = R.global.ItemRouter.characters[index]
    self.characterData.faction = R.playerFaction
    self.characterData.class = R.playerClass
    self.characterData.level = R.playerLevel
end
