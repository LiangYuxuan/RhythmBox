---@meta _
---@class LibKeystone
local LibKeystone = {}

---@alias LibKeystoneCallback fun(keyLevel: number, keyMapID: number, playerRating: number, playerName: string, channel: string)

---@param myUniqueTable table
---@param callback LibKeystoneCallback
function LibKeystone:Register(myUniqueTable, callback) end

---@param myUniqueTable table
function LibKeystone:Unregister(myUniqueTable) end

---@param channel 'PARTY' | 'GUILD'
function LibKeystone:Request(channel) end
