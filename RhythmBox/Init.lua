local addonName, Engine = ...

_G[addonName] = Engine

---@class RhythmBoxLibs
local Libs = {}
Engine.Libs = Libs

Libs.AceAddon = LibStub('AceAddon-3.0')
Libs.AceDB = LibStub('AceDB-3.0')
Libs.AceDBOptions = LibStub('AceDBOptions-3.0')
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
