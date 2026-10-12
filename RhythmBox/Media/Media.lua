local _, Engine = ...
local LSM = Engine.Libs.LSM
local koKR, ruRU, zhCN, zhTW, western = LSM.LOCALE_BIT_koKR, LSM.LOCALE_BIT_ruRU, LSM.LOCALE_BIT_zhCN, LSM.LOCALE_BIT_zhTW, LSM.LOCALE_BIT_western

---@type 'font'
local MediaType_FONT = LSM.MediaType.FONT

---@param mediaType string
---@param key string
---@param data string
---@param langMask number
local function ForceRegister(mediaType, key, data, langMask)
    ---@type boolean
    local result = LSM:Register(mediaType, key, data, langMask)
    if not result then
        local dataTable = LSM:HashTable(mediaType)
        dataTable[key] = data

        ---@diagnostic disable-next-line: undefined-field
        LSM.callbacks:Fire("LibSharedMedia_Registered", mediaType, key)
    end
end

-- -----
--   BACKGROUND
-- -----

-- -----
--   BORDER
-- ----

-- -----
--   FONT
-- -----
ForceRegister(MediaType_FONT, "GothamNarrowUltra", [[Interface\Addons\RhythmBox\Media\Font\GothamNarrowUltra_Round.ttf]], koKR + ruRU + zhCN + zhTW + western)
ForceRegister(MediaType_FONT, "Naowh", [[Interface\Addons\RhythmBox\Media\Font\Rhythm.ttf]], koKR + ruRU + zhCN + zhTW + western)

-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
