local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

---@class RhythmBoxColor
---@field r number
---@field g number
---@field b number
---@field a number?

---@class RhythmBoxColors
---@field White RhythmBoxColor
---@field Black RhythmBoxColor
---@field Gray RhythmBoxColor
---@field Red RhythmBoxColor
---@field Green RhythmBoxColor
---@field Blue RhythmBoxColor
---@field Yellow RhythmBoxColor
R.Colors = {
    White = {
        r = 1,
        g = 1,
        b = 1,
    },
    Black = {
        r = 0,
        g = 0,
        b = 0,
    },
    Gray = {
        r = 26 / 255,
        g = 26 / 255,
        b = 26 / 255,
    },
    Red = {
        r = 255 / 255,
        g = 107 / 255,
        b = 107 / 255,
    },
    Green = {
        r = 107 / 255,
        g = 203 / 255,
        b = 119 / 255,
    },
    Blue = {
        r = 77 / 255,
        g = 150 / 255,
        b = 255 / 255,
    },
    Yellow = {
        r = 255 / 255,
        g = 217 / 255,
        b = 61 / 255,
    },
}

---@param class string
---@return RhythmBoxColor
function R:ClassColor(class)
    local classColor = C_ClassColor.GetClassColor(class)

    ---@type RhythmBoxColor
    local color = {
        r = classColor.r,
        g = classColor.g,
        b = classColor.b,
    }
    return color
end
