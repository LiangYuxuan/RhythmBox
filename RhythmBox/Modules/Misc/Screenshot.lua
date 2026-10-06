local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxScreenshot: AceAddon-3.0 & AceEvent-3.0 & AceTimer-3.0
local SS = R:NewModule('Screenshot', 'AceEvent-3.0', 'AceTimer-3.0')

-- Lua functions
local table_insert = table.insert
local table_remove = table.remove

-- WoW API / Variables
local Screenshot = Screenshot

---@diagnostic disable-next-line: unused-function
function SS:HandleScreenshot()
    Screenshot()

    table_remove(self.queue, 1)
    if #self.queue > 0 then
        self:ScheduleTimer('HandleScreenshot', self.queue[1])
    end
end

---@param delay number
function SS:HandleDelayScreenshot(delay)
    table_insert(self.queue, delay)
    if #self.queue == 1 then
        self:ScheduleTimer('HandleScreenshot', delay)
    end
end

function SS:ACHIEVEMENT_EARNED()
    self:HandleDelayScreenshot(1)
end

function SS:CHALLENGE_MODE_COMPLETED()
    self:HandleDelayScreenshot(5)
end

function SS:OnDisable()
    self:UnregisterAllEvents()
end

function SS:OnEnable()
    self:RegisterEvent('ACHIEVEMENT_EARNED')
    self:RegisterEvent('CHALLENGE_MODE_COMPLETED')
end

function SS:OnInitialize()
    self.queue = {}
end
