---@meta _
---@class TSM_API
TSM_API = {}

---@alias TSM_API.uiName "AUCTION" | "CRAFTING" | "MAILING" | "VENDORING"

---@param uiName TSM_API.uiName
---@return boolean
function TSM_API.IsUIVisible(uiName)
end

---@param uiName TSM_API.uiName
---@param addonTag string
---@param func fun(show: boolean, frame: Frame?)
function TSM_API.RegisterUICallback(uiName, addonTag, func)
end

---@param uiName TSM_API.uiName
---@param addonTag string
---@param xOffset number
function TSM_API.ShiftDefaultUIButton(uiName, addonTag, xOffset)
end

---@param result table
---@return table
function TSM_API.GetGroupPaths(result)
end

---@param path string
---@return string
function TSM_API.FormatGroupPath(path)
end

---@param path string
---@return (string, string) | (nil)
function TSM_API.SplitGroupPath(path)
end

---@param itemString string
---@return string?
function TSM_API.GetGroupPathByItem(itemString)
end

---@param path string
---@param includeSubGroups boolean
---@param result table
---@return table
function TSM_API.GetGroupItems(path, includeSubGroups, result)
end

---@param addonTag string
---@param func function
function TSM_API.RegisterGroupItemCallback(addonTag, func)
end

---@param result table
---@return table
function TSM_API.GetProfiles(result)
end

---@return string
function TSM_API.GetActiveProfile()
end

---@param profile string
function TSM_API.SetActiveProfile(profile)
end

---@param result table
---@return table
function TSM_API.GetPriceSourceKeys(result)
end

---@param key string
---@return string
function TSM_API.GetPriceSourceDescription(key)
end

---@param customPriceStr string
---@return (true) | (false, string)
function TSM_API.IsCustomPriceValid(customPriceStr)
end

---@param customPriceStr string
---@param itemString string
---@return (number) | (nil, string)
function TSM_API.GetCustomPriceValue(customPriceStr, itemString)
end

---@param value number
---@return string
function TSM_API.FormatMoneyString(value)
end

---@param str string
---@return number
function TSM_API.ParseMoneyString(str)
end

---@param item string
---@return string
function TSM_API.ToItemString(item)
end

---@param itemString string
---@return string?
function TSM_API.GetItemName(itemString)
end

---@param itemString string
---@return string
function TSM_API.GetItemLink(itemString)
end

---@param itemString string
---@param character string?
---@param factionrealm string?
---@return number
function TSM_API.GetBagQuantity(itemString, character, factionrealm)
end

---@param itemString string
---@param character string?
---@param factionrealm string?
---@return number
function TSM_API.GetBankQuantity(itemString, character, factionrealm)
end

---@param itemString string
---@param character string?
---@param factionrealm string?
---@return number
function TSM_API.GetAuctionQuantity(itemString, character, factionrealm)
end

---@param itemString string
---@param character string?
---@param factionrealm string?
---@return number
function TSM_API.GetMailQuantity(itemString, character, factionrealm)
end

---@param itemString string
---@param guild string?
---@return number
function TSM_API.GetGuildQuantity(itemString, guild)
end

---@param itemString string
---@return number
function TSM_API.GetWarbankQuantity(itemString)
end

---@param itemString string
---@return number numPlayer, number numAlts, number numAuctions, number numAltAuctions
function TSM_API.GetPlayerTotals(itemString)
end

---@param itemString string
---@return number
function TSM_API.GetGuildTotal(itemString)
end

---@return function
function TSM_API.CraftingQueueIterator()
end

---@param recipeString string
---@param result table
---@return table
function TSM_API.GetCraftingQueueItemMaterials(recipeString, result)
end
