local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

-- Lua functions
local math_round = math.round
local string_format = string.format

-- WoW API / Variables
local C_ClassColor_GetClassColor = C_ClassColor.GetClassColor

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
    local classColor = C_ClassColor_GetClassColor(class)

    ---@type RhythmBoxColor
    local color = {
        r = classColor.r,
        g = classColor.g,
        b = classColor.b,
    }
    return color
end

---@param text string
---@param color RhythmBoxColor
---@return string
function R:WrapTextInColorCode(text, color)
    return string_format(
        '|c%.2X%.2X%.2X%.2X%s|r',
        ---@diagnostic disable-next-line: missing-parameter
        math_round((color.a or 1) * 255),
        ---@diagnostic disable-next-line: missing-parameter
        math_round(color.r * 255),
        ---@diagnostic disable-next-line: missing-parameter
        math_round(color.g * 255),
        ---@diagnostic disable-next-line: missing-parameter
        math_round(color.b * 255),
        text
    )
end
