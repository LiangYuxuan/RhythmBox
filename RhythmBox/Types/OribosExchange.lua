---@meta _

---@class OribosExchangeMarketInfo
---@field input number | string
---@field itemid number?
---@field species string?
---@field breed number?
---@field quality number?
---@field age number
---@field region number?
---@field market number?
---@field days number

---@param item number | string
---@param tbl table?
---@return OribosExchangeMarketInfo
function OEMarketInfo(item, tbl)
end
