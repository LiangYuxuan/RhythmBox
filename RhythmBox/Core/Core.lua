local addonName, Engine = ...
---@class RhythmBoxCore
---@field Name string
---@field Title string
---@field playerFullName string
---@field playerGUID string
---@field playerFaction string
---@field playerLocalizedFaction string
---@field playerLocalizedClass string
---@field playerClass string
---@field playerClassID number
local R = Engine.Core
local AceDB = Engine.Libs.AceDB

R.isDeveloper = false

--@debug@
---@diagnostic disable-next-line: duplicate-set-field
R.isDeveloper = true
--@end-debug@

R.Name = addonName
R.Title = '|cFF70B8FFRhythm Box|r'
R.playerFullName = UnitName('player') .. '-' .. GetRealmName()
---@type string
R.playerGUID = UnitGUID('player')
R.playerFaction, R.playerLocalizedFaction = UnitFactionGroup('player')
R.playerLocalizedClass, R.playerClass, R.playerClassID = UnitClass('player')

R.HiddenFrame = CreateFrame('Frame', nil, _G.UIParent)
R.HiddenFrame:SetPoint('BOTTOM')
R.HiddenFrame:SetSize(1, 1)
R.HiddenFrame:Hide()

_G.BINDING_HEADER_RHYTHM = R.Title

---@diagnostic disable-next-line: unused-function
function R:OnProfileUpdated()
    self.db = self.data.profile

    self:OptionsOnProfileUpdated()
end

function R:OnEnable()
    self:APIOnEnable()
    self:OptionsOnEnable()
end

function R:OnInitialize()
    ---@type { profile: RhythmBoxProfile } & AceDBObject-3.0
    self.data = AceDB:New('RhythmBoxDB', { profile = Engine.Profile }, true)
    self.data.RegisterCallback(self, 'OnProfileChanged', 'OnProfileUpdated')
    self.data.RegisterCallback(self, 'OnProfileCopied', 'OnProfileUpdated')
    self.data.RegisterCallback(self, 'OnProfileReset', 'OnProfileUpdated')

    ---@type RhythmBoxProfile
    self.db = self.data.profile

    self:APIOnInitialize()
end
