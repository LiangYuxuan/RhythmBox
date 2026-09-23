local addonName, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core
local AceDB = Engine.Libs.AceDB

R.isDeveloper = false

--@debug@
---@diagnostic disable-next-line: duplicate-set-field
R.isDeveloper = true
--@end-debug@

---@type string
R.Name = addonName
R.Title = '|cFF70B8FFRhythm Box|r'
R.playerFullName = UnitName('player') .. '-' .. GetRealmName()
---@type string
R.playerGUID = UnitGUID('player')

function R:OnProfileUpdated()
    self.db = self.data.profile

    self:OptionsOnProfileUpdated()
end

function R:OnEnable()
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
end
