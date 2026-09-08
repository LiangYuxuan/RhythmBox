---@meta _
---@class LibRangeCheck-3.0
local rc = {}

---@alias LibRangeCheck-3.0Checker fun(unit: string): boolean

---@alias LibRangeCheck-3.0Iterator fun(): number, LibRangeCheck-3.0Checker

---@type 'CHECKERS_CHANGED'
rc.CHECKERS_CHANGED = 'CHECKERS_CHANGED'

---@type number
rc.MeleeRange = 2

---@param spell number | string
---@return number?
function rc:findSpellIndex(spell) end

---returns the range estimate as a string
---@deprecated use `:getRange(unit)` instead and build your own strings
---@param unit string
---@param checkVisible boolean if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
---@param showOutOfRange boolean
---@return string? rangeString
function rc:getRangeAsString(unit, checkVisible, showOutOfRange) end

---initialize RangeCheck if not yet initialized or if "forced"
---@param forced boolean
function rc:init(forced) end

---Return an iterator for checkers usable on friendly units as (**range**, **checker**) pairs.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Iterator
function rc:GetFriendCheckers(inCombat) end

---Return an iterator for checkers usable on friendly units as (**range**, **checker**) pairs.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Iterator
function rc:GetFriendCheckersNoItems(inCombat) end

---Return an iterator for checkers usable on enemy units as (**range**, **checker**) pairs.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Iterator
function rc:GetHarmCheckers(inCombat) end

---Return an iterator for checkers usable on enemy units as (**range**, **checker**) pairs.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Iterator
function rc:GetHarmCheckersNoItems(inCombat) end

---Return a checker suitable for out-of-range checking on friendly units, that is, a checker whose range is equal or larger than the requested range.
---returns **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return (LibRangeCheck-3.0Checker checker, number range) | (nil, nil)
function rc:GetFriendMinChecker(range, inCombat) end

---Return a checker suitable for out-of-range checking on enemy units, that is, a checker whose range is equal or larger than the requested range.
---returns **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return (LibRangeCheck-3.0Checker checker, number range) | (nil, nil)
function rc:GetHarmMinChecker(range, inCombat) end

---Return a checker suitable for out-of-range checking on miscellaneous units, that is, a checker whose range is equal or larger than the requested range.
---returns **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return (LibRangeCheck-3.0Checker checker, number range) | (nil, nil)
function rc:GetMiscMinChecker(range, inCombat) end

---Return a checker suitable for in-range checking on friendly units, that is, a checker whose range is equal or smaller than the requested range.
---returns **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return (LibRangeCheck-3.0Checker checker, number range) | (nil, nil)
function rc:GetFriendMaxChecker(range, inCombat) end

---Return a checker suitable for in-range checking on enemy units, that is, a checker whose range is equal or smaller than the requested range.
---returns **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return (LibRangeCheck-3.0Checker checker, number range) | (nil, nil)
function rc:GetHarmMaxChecker(range, inCombat) end

---Return a checker suitable for in-range checking on miscellaneous units, that is, a checker whose range is equal or smaller than the requested range.
---returns **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return (LibRangeCheck-3.0Checker checker, number range) | (nil, nil)
function rc:GetMiscMaxChecker(range, inCombat) end

---Return a checker for the given range for friendly units.
---returns **checker** function or **nil** if no suitable checker is available.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Checker? checker
function rc:GetFriendChecker(range, inCombat) end

---Return a checker for the given range for enemy units.
---returns **checker** function or **nil** if no suitable checker is available.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Checker? checker
function rc:GetHarmChecker(range, inCombat) end

---Return a checker for the given range for miscellaneous units.
---returns **checker** function or **nil** if no suitable checker is available.
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Checker? checker
function rc:GetMiscChecker(range, inCombat) end

---Return a checker suitable for out-of-range checking that checks the unit type and calls the appropriate checker (friend/harm/misc).
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Checker checker
function rc:GetSmartMinChecker(range, inCombat) end

---Return a checker suitable for in-range checking that checks the unit type and calls the appropriate checker (friend/harm/misc).
---@param range number the range to check for.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Checker checker
function rc:GetSmartMaxChecker(range, inCombat) end

---Return a checker for the given range that checks the unit type and calls the appropriate checker (friend/harm/misc).
---@param range number the range to check for.
---@param fallback LibRangeCheck-3.0Checker? fallback function that gets called as fallback(unit) if a checker is not available for the given type (friend/harm/misc) at the requested range. The default fallback function return nil.
---@param inCombat boolean if true, only checkers that can be used in combat ar returned
---@return LibRangeCheck-3.0Checker checker
function rc:GetSmartChecker(range, fallback, inCombat) end

---Get a range estimate as **minRange**, **maxRange**.
---returns **minRange**, **maxRange** pair if a range estimate could be determined, **nil** otherwise. **maxRange** is **nil** if **unit** is further away than the highest possible range we can check.
---Includes checks for unit validity and friendly/enemy status.
---@param unit string the target unit to check range to.
---@param checkVisible boolean? if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
---@param noItems boolean? if set to true, no items and only spells are being used for the range check
---@param maxCacheAge number? the timespan a cached range value is considered valid (default 0.1 seconds, maximum 1 second)
---@return number? minRange, number? maxRange
function rc:GetRange(unit, checkVisible, noItems, maxCacheAge) end

---@deprecated use `:GetRange` instead
---Get a range estimate as **minRange**, **maxRange**.
---returns **minRange**, **maxRange** pair if a range estimate could be determined, **nil** otherwise. **maxRange** is **nil** if **unit** is further away than the highest possible range we can check.
---Includes checks for unit validity and friendly/enemy status.
---@param unit string the target unit to check range to.
---@param checkVisible boolean? if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
---@param noItems boolean? if set to true, no items and only spells are being used for the range check
---@param maxCacheAge number? the timespan a cached range value is considered valid (default 0.1 seconds, maximum 1 second)
---@return number? minRange, number? maxRange
function rc:getRange(unit, checkVisible, noItems, maxCacheAge) end

---@param event 'CHECKERS_CHANGED'
---@param callback fun()
function rc:RegisterCallback(event, callback) end
