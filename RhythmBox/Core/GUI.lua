local _, Engine = ...
---@class RhythmBoxCore
local R = Engine.Core

-- Lua functions
local _G = _G

-- WoW API / Variables
local CreateFrame = CreateFrame

local defaultFont = [[Interface\AddOns\RhythmBox\Media\Font\Rhythm.ttf]]
local arrowTexture = [[Interface\AddOns\RhythmBox\Media\Texture\ArrowUp.tga]]
local closeTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Close.tga]]
local copyTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Copy.tga]]
local edgeTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Edge.tga]]
local edgeAltTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Edge2.tga]]
local invisibleTexture = [[Interface\AddOns\RhythmBox\Media\Texture\Invisible.tga]]
local whiteTexture = [[Interface\AddOns\RhythmBox\Media\Texture\WHITE8x8.tga]]

---@class RhythmBoxTexture
---@field default string
---@field copy string
R.texture = {
    default = whiteTexture,
    copy = copyTexture,
}

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
---@param offset number?
local function SetInside(region, parent, offset)
    offset = offset or 1

    region:ClearAllPoints()
    region:SetPoint('TOPLEFT', parent, 'TOPLEFT', offset, -offset)
    region:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -offset, offset)
end

---@param region Region
---@param parent Region
---@param offset number?
local function SetOutside(region, parent, offset)
    offset = offset or 1

    region:ClearAllPoints()
    region:SetPoint('TOPLEFT', parent, 'TOPLEFT', -offset, offset)
    region:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', offset, -offset)
end

---@param texture Texture
---@param parent Frame
function R:SetupIcon(texture, parent)
    SetInside(texture, parent)
    texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

---@param font FontString
---@param fontSize number?
---@param fontStyle string?
---@param useShadow boolean?
function R:SetupFont(font, fontSize, fontStyle, useShadow)
    font:SetFont(defaultFont, fontSize or 14, fontStyle or 'OUTLINE')

    if useShadow then
        font:SetShadowColor(0, 0, 0, fontStyle == '' and 1 or 0.6)
        font:SetShadowOffset(1, -1)
    else
        font:SetShadowColor(0, 0, 0, 0)
        font:SetShadowOffset(0, 0)
    end
end

---@param frame Frame
function R:MixinBackdrop(frame)
    if not frame.SetBackdrop then
        _G.Mixin(frame, _G.BackdropTemplateMixin)

        ---@cast frame Frame & BackdropTemplate
        frame:HookScript('OnSizeChanged', frame.OnBackdropSizeChanged)
    end
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

---@param region Region
---@param template "Default" | "Transparent" | nil
---@param allPoints boolean?
function R:CreateBackdrop(region, template, allPoints)
    local parent = region.IsObjectType and region:IsObjectType('Texture') and region:GetParent() or region
    local backdrop = region.backdrop or CreateFrame('Frame', nil, parent, 'BackdropTemplate')
    region.backdrop = backdrop

    self:SetupBackdrop(backdrop, template)

    if allPoints then
        backdrop:SetAllPoints(region)
    else
        SetOutside(backdrop, region)
    end

    local frameLevel = parent:GetFrameLevel() - 1
    backdrop:SetFrameLevel(frameLevel > 0 and frameLevel or 0)
end

---@param button Button
---@param highlightAlpha number?
function R:SetupButtonHighlight(button, highlightAlpha)
    button:SetHighlightTexture(whiteTexture)
    button:SetPushedTexture(whiteTexture)

    local hover = button:GetHighlightTexture()
    local pushed = button:GetPushedTexture()

    SetInside(hover, button)
    hover:SetBlendMode('ADD')
    hover:SetVertexColor(1, 1, 1, highlightAlpha or 0.3)

    SetInside(pushed, button)
    pushed:SetBlendMode('ADD')
    pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)
end

---@param button Button
function R:SetupCloseButton(button)
    button:SetSize(18, 18)

    button:SetNormalTexture(closeTexture)
    button:SetDisabledTexture(closeTexture)
    button:SetHighlightTexture(closeTexture)
    button:SetPushedTexture(closeTexture)

    local normal = button:GetNormalTexture()
    local disabled = button:GetDisabledTexture()
    local hover = button:GetHighlightTexture()
    local pushed = button:GetPushedTexture()
    local color = self.playerClassColor

    SetInside(normal, button, 3)
    normal:SetTexCoord(0, 1, 0, 1)
    normal:SetVertexColor(1, 1, 1)

    SetInside(disabled, button, 3)
    disabled:SetTexCoord(0, 1, 0, 1)
    disabled:SetVertexColor(0.3, 0.3, 0.3)

    SetInside(hover, button, 3)
    hover:SetTexCoord(0, 1, 0, 1)
    hover:SetVertexColor(color.r, color.g, color.b, 1)
    hover:SetBlendMode('BLEND')

    SetInside(pushed, button, 3)
    pushed:SetTexCoord(0, 1, 0, 1)
end

do
    local arrowRotation = { up = 0, down = 3.14, left = 1.57, right = -1.57 }

    ---@param button Button
    ---@param direction "up" | "down" | "left" | "right"
    function R:SetupArrowButton(button, direction)
        button:SetSize(18, 18)

        button:SetNormalTexture(arrowTexture)
        button:SetDisabledTexture(arrowTexture)
        button:SetHighlightTexture(arrowTexture)
        button:SetPushedTexture(arrowTexture)

        local normal = button:GetNormalTexture()
        local disabled = button:GetDisabledTexture()
        local hover = button:GetHighlightTexture()
        local pushed = button:GetPushedTexture()
        local color = self.playerClassColor

        local rotation = arrowRotation[direction]

        SetInside(normal, button)
        normal:SetTexCoord(0, 1, 0, 1)
        normal:SetVertexColor(1, 1, 1)
        normal:SetRotation(rotation)

        SetInside(disabled, button)
        disabled:SetTexCoord(0, 1, 0, 1)
        disabled:SetVertexColor(0.3, 0.3, 0.3)
        disabled:SetRotation(rotation)

        SetInside(hover, button)
        hover:SetTexCoord(0, 1, 0, 1)
        hover:SetVertexColor(color.r, color.g, color.b, 1)
        hover:SetBlendMode('BLEND')
        hover:SetRotation(rotation)

        SetInside(pushed, button)
        pushed:SetTexCoord(0, 1, 0, 1)
        pushed:SetRotation(rotation)
    end
end

---@param scrollBar EventFrame & MinimalScrollBar
function R:SetupScrollBar(scrollBar)
    local upButton = scrollBar.Back
    local downButton = scrollBar.Forward
    local track = scrollBar.Track
    ---@type MinimalScrollBar_Track_Thumb & BackdropTemplate
    local thumb = track.Thumb

    upButton.Texture:Hide()
    downButton.Texture:Hide()

    self:SetupArrowButton(upButton, 'up')
    self:SetupArrowButton(downButton, 'down')

    track.Begin:Hide()
    track.End:Hide()
    track.Middle:Hide()

    thumb.Begin:Hide()
    thumb.End:Hide()
    thumb.Middle:Hide()

    R:MixinBackdrop(thumb)
    R:SetupBackdrop(thumb)
    R:SetupButtonHighlight(thumb, 0.1)

    local color = self.playerClassColor
    thumb:SetBackdropColor(color.r, color.g, color.b, 0.3)
end

---@param cooldown Cooldown & CooldownFrameTemplate
---@param parent Frame
---@param cooldownType "Default" | "Charge" | "LossOfControl" | nil
function R:SetupCooldown(cooldown, parent, cooldownType)
    SetInside(cooldown, parent)

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

    cooldown:SetCountdownFormatter(formatter)

    cooldown:SetDrawBling(true)
    cooldown:SetReverse(false)
end

do
    ---@param self RhythmBoxTextButton
    ---@param text string?
    local function SetText(self, text)
        self.text:SetText(text)
    end

    ---@param parent Frame
    ---@param fontSize number?
    ---@param normalColor RhythmBoxColor?
    ---@param disabledColor RhythmBoxColor?
    ---@param normalAlpha number?
    ---@param disabledAlpha number?
    ---@return RhythmBoxTextButton
    function R:CreateTextButton(parent, fontSize, normalColor, disabledColor, normalAlpha, disabledAlpha)
        ---@class RhythmBoxTextButton: Button & BackdropTemplate
        ---@field SetText fun(self: self, text: string?)
        local button = CreateFrame('Button', nil, parent, 'BackdropTemplate')
        self:SetupBackdrop(button)
        self:SetupButtonHighlight(button, normalColor and 0.03 or 0.3)

        button:SetNormalTexture(whiteTexture)
        button:SetDisabledTexture(whiteTexture)

        local normal = button:GetNormalTexture()
        local disabled = button:GetDisabledTexture()

        normal:ClearAllPoints()
        normal:SetAllPoints()
        if normalColor then
            normal:SetVertexColor(normalColor.r, normalColor.g, normalColor.b, normalAlpha or normalColor.a or 0.1)
        else
            normal:SetVertexColor(0, 0, 0, normalAlpha or 0.1)
        end

        disabled:ClearAllPoints()
        disabled:SetAllPoints()
        if disabledColor then
            disabled:SetVertexColor(disabledColor.r, disabledColor.g, disabledColor.b, disabledAlpha or disabledColor.a or 0.1)
        else
            disabled:SetVertexColor(0, 0, 0, disabledAlpha or 0.1)
        end

        button.text = button:CreateFontString(nil, 'ARTWORK')
        button.text:SetPoint('CENTER')
        button.text:SetTextColor(1, 1, 1)
        self:SetupFont(button.text, fontSize)

        button.SetText = SetText

        return button
    end
end
