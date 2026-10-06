local _, Engine = ...
local R = Engine.Core
---@class RhythmBoxAutoLogging: AceAddon-3.0 & AceEvent-3.0 & AceTimer-3.0
local AL = R:NewModule('AutoLogging', 'AceEvent-3.0', 'AceTimer-3.0')

-- Lua functions
local ipairs = ipairs
local table_wipe = table.wipe

-- WoW API / Variables
local C_ChallengeMode_GetMapTable = C_ChallengeMode.GetMapTable
local GetInstanceInfo = GetInstanceInfo
local LoggingCombat = LoggingCombat
local SetCVar = SetCVar

---@type table<number, boolean>
local instances = {
    ---AUTO_GENERATED LEADING AutoLogging
    -- Dungeons
    [2805] = true, -- Windrunner Spire
    [2811] = true, -- Magisters' Terrace
    [2813] = true, -- Murder Row
    [2825] = true, -- Den of Nalorakk
    [2859] = true, -- The Blinding Vale
    [2874] = true, -- Maisara Caverns
    [2915] = true, -- Nexus-Point Xenas
    [2923] = true, -- Voidscar Arena
    [2993] = true, -- Altar of Fangs
    -- Raids
    [1592] = true, -- Sporefall
    [2912] = true, -- The Voidspire
    [2913] = true, -- March on Quel'Danas
    [2939] = true, -- The Dreamrift
    [2987] = true, -- The Tidebound Grotto
    [3004] = true, -- The Venomous Abyss
    [3095] = true, -- The Unbinding of Kith'ix
    ---AUTO_GENERATED TAILING AutoLogging
}

---@type table<number, boolean>
local seasonInstances = {}

---@diagnostic disable-next-line: unused-function
function AL:DelayedStopLogging()
    LoggingCombat(false)
    R:Print("停止记录战斗日志")

    self.timer = nil
end

---@return boolean?, boolean?
function AL:IsShouldLogging()
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    if (
        instanceType == 'raid' and (instances[instanceID] or seasonInstances[instanceID]) and
        (difficultyID == 14 or difficultyID == 15 or difficultyID == 16 or difficultyID == 233)
    ) then
        return true
    elseif (
        instanceType == 'party' and (instances[instanceID] or seasonInstances[instanceID]) and
        (difficultyID == 8 or difficultyID == 23)
    ) then
        return true, difficultyID == 8
    end
end

---@param event string
---@param ... any
function AL:UpdateLogging(event, ...)
    if event == 'PLAYER_ENTERING_WORLD' then
        ---@type boolean, boolean
        local isInitialLogin, isReloadingUi = ...
        if not isInitialLogin and not isReloadingUi then
            return
        end
    end

    local isActive = LoggingCombat()
    local shouldLogging, isInstanceMP = self:IsShouldLogging()

    if shouldLogging then
        if self.timer then
            self:CancelTimer(self.timer)
            self.timer = nil
        end

        if not isActive then
            LoggingCombat(true)
            R:Print("开始记录战斗日志")
        end
    elseif isActive then
        -- if last instance is mythic+ and completed, don't delay stop logging
        if not self.isInstanceMP or self.isInstanceMPCompleted then
            if self.timer then
                self:CancelTimer(self.timer)
                self.timer = nil
            end

            LoggingCombat(false)
            R:Print("停止记录战斗日志")
        elseif not self.timer then
            self.timer = self:ScheduleTimer('DelayedStopLogging', 20)
        end
    end

    self.isInstanceMP = isInstanceMP
    self.isInstanceMPCompleted = false
end

function AL:UpdateMPCompleted()
    self.isInstanceMPCompleted = true
end

function AL:OnDisable()
    table_wipe(seasonInstances)

    self:UnregisterAllEvents()
end

function AL:OnEnable()
    local database = Engine.Database.MythicPlus
    local mapChallengeModeIDs = C_ChallengeMode_GetMapTable()
    for _, mapChallengeModeID in ipairs(mapChallengeModeIDs) do
        local data = database[mapChallengeModeID]
        if data then
            seasonInstances[data.mapID] = true
        end
    end

    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateLogging')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'UpdateLogging')
    self:RegisterEvent('CHALLENGE_MODE_START', 'UpdateLogging')
    self:RegisterEvent('CHALLENGE_MODE_COMPLETED', 'UpdateMPCompleted')
end

function AL:OnInitialize()
    SetCVar('advancedCombatLogging', '1')
end
