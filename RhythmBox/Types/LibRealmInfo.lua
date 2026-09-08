---@meta _
---@class LibRealmInfo
local lib = {}

---@return string?
function lib:GetCurrentRegion() end

---@param name string The name of the realm to query
---@param region string? The region to query. If not specified, the player's region will be used.
---@return number id, string name, string nameForAPI, string rules, string locale, nil, string region, string? timezone, number[]? connectedIDs, string? englishName, string? englishNameForAPI
function lib:GetRealmInfo(name, region) end

---@param id number The ID for the realm to query (strings will be converted to numbers)
---@return number id, string name, string nameForAPI, string rules, string locale, nil, string region, string? timezone, number[]? connectedIDs, string? englishName, string? englishNameForAPI
function lib:GetRealmInfoByID(id) end

---@param guid string The GUID of the unit whose realm to query.
---@return number id, string name, string nameForAPI, string rules, string locale, nil, string region, string? timezone, number[]? connectedIDs, string? englishName, string? englishNameForAPI
function lib:GetRealmInfoByGUID(guid) end

---@param unit string The unit token (eg. "target") of the unit whose realm to query.
---@return number id, string name, string nameForAPI, string rules, string locale, nil, string region, string? timezone, number[]? connectedIDs, string? englishName, string? englishNameForAPI
function lib:GetRealmInfoByUnit(unit) end
