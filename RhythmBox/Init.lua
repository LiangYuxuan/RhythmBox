local addonName, Engine = ...

-- GLOBALS: _G

_G[addonName] = Engine

---@class RhythmBoxLibs
local Libs = {}
Engine.Libs = Libs

Libs.AceAddon = LibStub('AceAddon-3.0')
Libs.AceDB = LibStub('AceDB-3.0')
Libs.AceDBOptions = LibStub('AceDBOptions-3.0')
Libs.AceConsole = LibStub('AceConsole-3.0')
Libs.AceGUI = LibStub('AceGUI-3.0')
Libs.AceConfig = LibStub('AceConfig-3.0')
Libs.AceConfigDialog = LibStub('AceConfigDialog-3.0')
Libs.AceConfigRegistry = LibStub('AceConfigRegistry-3.0')

Libs.LSM = LibStub('LibSharedMedia-3.0')
Libs.LDB = LibStub('LibDataBroker-1.1')
Libs.LDBI = LibStub('LibDBIcon-1.0')
Libs.LK = LibStub('LibKeystone')
Libs.LRC = LibStub('LibRangeCheck-3.0')
Libs.LRI = LibStub('LibRealmInfo')
Libs.LOP = LibStub('LibObjectiveProgress-1.0')
Libs.LOR = LibStub('LibOpenRaid-1.0')

---@class RhythmBoxProfile
local P = {}
Engine.Profile = P

---@class RhythmBoxCore: AceAddon-3.0 & AceEvent-3.0
local R = Libs.AceAddon:NewAddon(addonName, 'AceEvent-3.0')
Engine.Core = R

---@param errorMessage string
---@return nil
local function ErrorHandler(errorMessage)
    _G.geterrorhandler()(errorMessage)
end

R.ErrorHandler = ErrorHandler
