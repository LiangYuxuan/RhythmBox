local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

local defaultFont = [[Interface\AddOns\RhythmBox\Media\Font\Rhythm.ttf]]
local edgeTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Edge.tga]]
local edgeAltTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Edge2.tga]]
local invisibleTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Invisible.tga]]
local whiteTexture = [[Interface\AddOns\RhythmBox\Media\Texture\WHITE8x8.tga]]

---@type backdropInfo
local backdropInfo = {
    bgFile = whiteTexture,
    edgeFile = whiteTexture,
    edgeSize = 1,
}

---@type NumericRuleFormatBreakpoint[]
local breakpoints = {
    {
        threshold = 0,
        step = 0.1,
        rounding = Enum.NumericRuleFormatRounding.Down,
        format = CreateColor(1, 0.2, 0.2, 1):WrapTextInColorCode('%.1f'),
    },
    {
        threshold = 5,
        step = 1,
        rounding = Enum.NumericRuleFormatRounding.Down,
        format = CreateColor(1, 1, 0.2, 1):WrapTextInColorCode('%.0f'),
    },
    {
        threshold = 10,
        step = 1,
        rounding = Enum.NumericRuleFormatRounding.Down,
        format = CreateColor(1, 1, 1, 1):WrapTextInColorCode('%.0f'),
    },
    {
        threshold = 60,
        format = CreateColor(1, 1, 1, 1):WrapTextInColorCode('%.0fm'),
        components = {
            {
                div = 60,
                rounding = Enum.NumericRuleFormatRounding.Down,
            }
        },
    },
    {
        threshold = 3600,
        format = CreateColor(0.4, 1, 1, 1):WrapTextInColorCode('%.0fh'),
        components = {
            {
                div = 3600,
                rounding = Enum.NumericRuleFormatRounding.Down,
            }
        },
    },
    {
        threshold = 86400,
        format = CreateColor(0.4, 0.4, 1, 1):WrapTextInColorCode('%.0fd'),
        components = {
            {
                div = 86400,
                rounding = Enum.NumericRuleFormatRounding.Down,
            }
        },
    },
}

local formatter = C_StringUtil.CreateNumericRuleFormatter()
formatter:SetBreakpoints(breakpoints)

---@param region Region
---@param parent Region
local function SetInside(region, parent)
    region:ClearAllPoints()
    region:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, -1)
    region:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -1, 1)
end

---@param frame Frame & BackdropTemplate
---@param template "Default" | "Transparent" | nil
function R:SetupBackdrop(frame, template)
    frame:SetBackdrop(backdropInfo)

    if template == 'Transparent' then
        frame:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
    else -- Default
        frame:SetBackdropColor(0.1, 0.1, 0.1, 1)
    end

    frame:SetBackdropBorderColor(0, 0, 0, 1)
end

---@param button Button
function R:SetupButtonHighlight(button)
    button:SetHighlightTexture(whiteTexture)
    button:SetPushedTexture(whiteTexture)

    local hover = button:GetHighlightTexture()
    local pushed = button:GetPushedTexture()

    SetInside(hover, button)
    hover:SetBlendMode('ADD')
    hover:SetVertexColor(1, 1, 1, 0.3)

    SetInside(pushed, button)
    pushed:SetBlendMode('ADD')
    pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)
end

---@param texture Texture
---@param parent Frame
function R:SetupIcon(texture, parent)
    texture:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, -1)
    texture:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -1, 1)
    texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

---@param font FontString
---@param fontSize number?
---@param fontStyle string?
---@param useShadow boolean?
function R:SetupFont(font, fontSize, fontStyle, useShadow)
    font:SetFont(defaultFont, fontSize or 12, fontStyle or 'OUTLINE')

    if useShadow then
        font:SetShadowColor(0, 0, 0, fontStyle == '' and 1 or 0.6)
        font:SetShadowOffset(1, -1)
    else
        font:SetShadowColor(0, 0, 0, 0)
        font:SetShadowOffset(0, 0)
    end
end

---@param cooldown Cooldown & CooldownFrameTemplate
---@param parent Frame
---@param cooldownType "Default" | "Charge" | "LossOfControl" | nil
function R:SetupCooldown(cooldown, parent, cooldownType)
    cooldown:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, -1)
    cooldown:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -1, 1)

    ---@diagnostic disable-next-line: missing-parameter
    cooldown:SetBlingTexture(invisibleTexture)

    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetCountdownAbbrevThreshold(1500)
    cooldown:SetMinimumCountdownDuration(1500)

    ---@type FontString
    local text = cooldown:GetRegions()
    text:ClearAllPoints()
    text:SetPoint('CENTER', 0, 0)
    text:SetTextColor(0.8, 0.8, 0.8, 1)
    text:SetFont(defaultFont, 16, 'OUTLINE')

    cooldown:SetDrawEdge(true)
    cooldown:SetDrawSwipe(true)

    if cooldownType == 'Charge' then
        cooldown:SetEdgeColor(0.6, 1, 0, 1)
        cooldown:SetSwipeColor(0, 0.6, 1, 0.3)
        cooldown:SetEdgeTexture(edgeAltTexture, 0.6, 1, 0, 1)
        cooldown:SetSwipeTexture(whiteTexture, 0, 0.6, 1, 0.3)
    elseif cooldownType == 'LossOfControl' then
        cooldown:SetEdgeColor(1, 0.2, 0.8, 1)
        cooldown:SetSwipeColor(1, 0.2, 0.6, 0.3)
        cooldown:SetEdgeTexture(edgeTexture, 1, 0.2, 0.8, 1)
        cooldown:SetSwipeTexture(whiteTexture, 1, 0.2, 0.6, 0.3)
    else
        cooldown:SetEdgeColor(0, 0, 0, 1)
        cooldown:SetSwipeColor(0, 0, 0, 0.7)
        cooldown:SetEdgeTexture(edgeTexture, 0, 0, 0, 1)
        cooldown:SetSwipeTexture(whiteTexture, 0, 0, 0, 0.7)
    end

    ---@diagnostic disable-next-line: type-mismatch
    cooldown:SetCountdownFormatter(formatter)

    cooldown:SetDrawBling(true)
    cooldown:SetReverse(false)
end
