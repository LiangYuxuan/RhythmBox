local _, Engine = ...
local LSM = Engine.Libs.LSM
local koKR, ruRU, zhCN, zhTW, western = LSM.LOCALE_BIT_koKR, LSM.LOCALE_BIT_ruRU, LSM.LOCALE_BIT_zhCN, LSM.LOCALE_BIT_zhTW, LSM.LOCALE_BIT_western

---@type 'font'
local MediaType_FONT = LSM.MediaType.FONT

-- -----
--   BACKGROUND
-- -----

-- -----
--   BORDER
-- ----

-- -----
--   FONT
-- -----
do
    -- GothamNarrowUltra + Rhythm and hijack GothamNarrowUltra font in NaowhUI
    ---@type boolean
    local res = LSM:Register(MediaType_FONT, "GothamNarrowUltra", [[Interface\Addons\RhythmBox\Media\Font\GothamNarrowUltra_Round.ttf]], koKR + ruRU + zhCN + zhTW + western)
    if not res then
        local data = LSM:HashTable(MediaType_FONT)
        data["GothamNarrowUltra"] = [[Interface\Addons\RhythmBox\Media\Font\GothamNarrowUltra_Round.ttf]]
    end
end
do
    -- hijack Naowh font in NaowhUI
    ---@type boolean
    local res = LSM:Register(MediaType_FONT, "Naowh", [[Interface\Addons\RhythmBox\Media\Font\Rhythm.ttf]], koKR + ruRU + zhCN + zhTW + western)
    if not res then
        local data = LSM:HashTable(MediaType_FONT)
        data["Naowh"] = [[Interface\Addons\RhythmBox\Media\Font\Rhythm.ttf]]
    end
end

-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
