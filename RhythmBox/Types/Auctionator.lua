---@meta _
---@class Auctionator.API.v1
local v1 = {}
---@class Auctionator.API
---@field v1 Auctionator.API.v1
local API = { v1 = v1 }
---@class Auctionator
---@field API Auctionator.API
Auctionator = { API = API }

---@param callerID string
---@param itemID number
---@return number?
function v1.GetAuctionPriceByItemID(callerID, itemID)
end

---@param callerID string
---@param itemLink string
---@return number?
function v1.GetAuctionPriceByItemLink(callerID, itemLink)
end

---@param callerID string
---@param terms string[]
---@return string[]
function v1.MultiSearch(callerID, terms)
end
