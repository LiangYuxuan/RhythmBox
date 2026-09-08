---@meta _
---@class LibOpenRaid-1.0
local openRaidLib = {}

---@alias (opaque) LibOpenRaid-1.0UnitCooldownInfo [number, number, number, number, number, number]

---@class LibOpenRaid-1.0PlayerGearEquippedGear
---@field slotId number
---@field gemSlots number
---@field itemLevel number
---@field itemLink string
---@field itemQuality number
---@field itemId number
---@field itemName string
---@field enchantId number
---@field gemId number
---@field isTier boolean

---@class LibOpenRaid-1.0PlayerGear
---@field durability number
---@field ilevel number
---@field noGems number[]
---@field noEnchants number[]
---@field weaponEnchant number
---@field equippedGear LibOpenRaid-1.0PlayerGearEquippedGear[]

---@class LibOpenRaid-1.0UnitInformation
---@field specId number
---@field specName string
---@field role string
---@field heroTalentId number
---@field talents string dragonflight talent string, e.g: "CkGAvcQZXENQPQXqed372Hg2KuxMzssYmZmZWegZZYGjFGLjZAAAAAAAAAAAAsBDzwYGNzAmxYmxgplZGAAAAAwAAAgltxGmmZWGCAABsgZmBA"
---@field pvpTalents [number, number, number]
---@field class string class eng name 'ROGUE'
---@field classId number
---@field className string class localized name 'Rogue'
---@field name string name without realm
---@field nameFull string name with realm 'unitName-ServerName'

---@class LibOpenRaid-1.0KeystoneInfo
---@field level number
---@field mapID number
---@field challengeMapID number
---@field classID number
---@field rating number
---@field mythicPlusMapID number

---@event LibOpenRaid-1.0Event
---| "CooldownListUpdate" -> unitId: string, unitCooldowns: table<number, LibOpenRaid-1.0UnitCooldownInfo>, allUnitsCooldowns: table<string, table<number, LibOpenRaid-1.0UnitCooldownInfo>>
---| "CooldownUpdate" -> unitId: string, spellId: number, cooldownInfo: LibOpenRaid-1.0UnitCooldownInfo, unitCooldowns: table<number, LibOpenRaid-1.0UnitCooldownInfo>, allUnitsCooldowns: table<string, table<number, LibOpenRaid-1.0UnitCooldownInfo>>
---| "CooldownAdded" -> unitId: string, spellId: number, cooldownInfo: LibOpenRaid-1.0UnitCooldownInfo, unitCooldowns: table<number, LibOpenRaid-1.0UnitCooldownInfo>, allUnitsCooldowns: table<string, table<number, LibOpenRaid-1.0UnitCooldownInfo>>
---| "CooldownRemoved" -> unitId: string, spellId: number, unitCooldowns: table<number, LibOpenRaid-1.0UnitCooldownInfo>, allUnitsCooldowns: table<string, table<number, LibOpenRaid-1.0UnitCooldownInfo>>
---| "CooldownListWipe" -> allUnitsCooldowns: table<string, table<number, LibOpenRaid-1.0UnitCooldownInfo>>
---| "GearUpdate" -> unitId: string, unitGear: LibOpenRaid-1.0PlayerGear, allUnitsGear: table<string, LibOpenRaid-1.0PlayerGear>
---| "GearDurabilityUpdate" -> unitId: string, durability: number, unitGear: LibOpenRaid-1.0PlayerGear, allUnitsGear: table<string, LibOpenRaid-1.0PlayerGear>
---| "GearListWipe" -> allUnitsGear: table<string, LibOpenRaid-1.0PlayerGear>
---| "UnitInfoUpdate" -> unitId: string, unitInfo: LibOpenRaid-1.0UnitInformation, allUnitsInfo: table<string, LibOpenRaid-1.0UnitInformation>
---| "UnitInfoWipe" -> allUnitsInfo: table<string, LibOpenRaid-1.0UnitInformation>
---| "UnitDeath" -> unitId: string
---| "UnitAlive" -> unitId: string
---| "KeystoneUpdate" -> unitName: string, keystoneInfo: LibOpenRaid-1.0KeystoneInfo, allKeystoneInfo: table<string, LibOpenRaid-1.0KeystoneInfo>
---| "KeystoneWipe" -> allKeystoneInfo: table<string, LibOpenRaid-1.0KeystoneInfo>

---Request to all players in the group to send infomation on: cooldowns, gear and player data.
---@return boolean sentRequest
function openRaidLib.RequestAllData() end

---get all cooldowns from all units
---@return table<string, table<number, LibOpenRaid-1.0UnitCooldownInfo>> allUnitsCooldowns
function openRaidLib.GetAllUnitsCooldown() end

---get all cooldowns from a single unit
---@param unitId string
---@param filter string "defensive-raid", "defensive-target", "defensive-personal", "ofensive", "utility", "interrupt", can pass more than one filter separating by comma, example: "defensive-raid, defensive-target"
---@return table<number, LibOpenRaid-1.0UnitCooldownInfo> unitCooldowns
function openRaidLib.GetUnitCooldowns(unitId, filter) end

---get a cooldownInfo of a single spell from any unit
---@param unitId string
---@param spellId number
---@return LibOpenRaid-1.0UnitCooldownInfo cooldownInfo
function openRaidLib.GetUnitCooldownInfo(unitId, spellId) end

---get cooldown timers to use with progress bar or cooldown frames
---@param unitId string
---@param spellId number
---@return boolean isReady, number normalizedPercent, number timeLeft, number charges, number minValue, number maxValue, number currentValue, number cooldownDuration
function openRaidLib.GetCooldownStatusFromUnitSpellID(unitId, spellId) end

----get cooldown timers to use with progress bar or cooldown frames
---@param cooldownInfo LibOpenRaid-1.0UnitCooldownInfo
---@return boolean isReady, number normalizedPercent, number timeLeft, number charges, number minValue, number maxValue, number currentValue, number cooldownDuration
function openRaidLib.GetCooldownStatusFromCooldownInfo(cooldownInfo) end

---add spells to a custom filter
---to change the spells in the filter just call it again with different spells, spells not included in the new table are removed from the filter
---to remove the filter, call it with an empty table
---@param filterName string any string containing alphanumeric characters
---@param spells number[] a table containing spellIds {spellId, spellId, spellId, ...}
function openRaidLib.AddCooldownFilter(filterName, spells) end

---get a list of filters which a spell has, returns a table in map format: {[filterName] = true}
---@param spellId number the ID of a spell
---@param defaultFilterOnly boolean if true only return built-in filters, example: "defensive-raid", "ofensive".
---@param customFiltersOnly boolean if true only return a list of custom filters where the spell was added.
---@return table<string, boolean> filterListArray
function openRaidLib.GetSpellFilters(spellId, defaultFilterOnly, customFiltersOnly) end

---request information about a spell for all units in the raid, units which has this cooldown will report back with a "CooldownUpdate" event
---@param spellId number
function openRaidLib.RequestCooldownInfo(spellId) end

---@return table<string, LibOpenRaid-1.0PlayerGear> allPlayersGear
function openRaidLib.GetAllUnitsGear() end

---@param unitId string
---@return LibOpenRaid-1.0PlayerGear playerGear
function openRaidLib.GetUnitGear(unitId) end

---@return table<string, LibOpenRaid-1.0UnitInformation> allUnitsInfo
function openRaidLib.GetAllUnitsInfo() end

---@param unitId string
---@return LibOpenRaid-1.0UnitInformation unitInfo
function openRaidLib.GetUnitInfo(unitId) end

---@return table<string, LibOpenRaid-1.0KeystoneInfo> allKeystoneInfo
function openRaidLib.GetAllKeystonesInfo() end

---@param unitId string
---@return LibOpenRaid-1.0KeystoneInfo keystoneInfo
function openRaidLib.GetKeystoneInfo(unitId) end

---request all online players in the guild to send their keystone information
---this call fails if the player isn't in a guild
---@return boolean sentRequest
function openRaidLib.RequestKeystoneDataFromGuild() end

---request to players in your party to send their keystone information
---this call fails if the player is in raid
---@return boolean sentRequest
function openRaidLib.RequestKeystoneDataFromParty() end

---request to players in your raid to send their keystone information
---this call fails if not in a raid group
---@return boolean sentRequest
function openRaidLib.RequestKeystoneDataFromRaid() end

---@param spellId number a regular spellId
---@return boolean? flaskInfo
function openRaidLib.GetFlaskInfoBySpellId(spellId) end

---@param auraInfo AuraData
---@return number? flaskTier
function openRaidLib.GetFlaskTierFromAura(auraInfo) end

---@param spellId number a regular spellId
---@return boolean? foodInfo
function openRaidLib.GetFoodInfoBySpellId(spellId) end

---@param auraInfo AuraData
---@return number? foodTier
function openRaidLib.GetFoodTierFromAura(auraInfo) end

---@generic T
---@generic E: LibOpenRaid-1.0Event
---@overload fun(addonObject: T, event: E, callbackMemberName: keyof T)
---@param addonObject T
---@param event E
---@param callbackMemberName fun(...params<E>)
function openRaidLib.RegisterCallback(addonObject, event, callbackMemberName) end
