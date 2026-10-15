local _, Engine = ...
---@class RhythmBoxDatabase
local Database = Engine.Database

---@class RhythmBoxDatabaseMythicPlus
---@field challengeMapID number
---@field mapID number
---@field LFGDungeonID number
---@field shortName string?
---@field portalSpellID number?

---@type table<number, RhythmBoxDatabaseMythicPlus?>
Database.MythicPlus = {
    ---AUTO_GENERATED LEADING DatabaseMythicPlus
    [249] = { -- Kings' Rest
        challengeMapID = 249,
        mapID = 1762,
        LFGDungeonID = 1762,
        shortName = "KR",
        portalSpellID = 1286831,
    },
    [250] = { -- Temple of Sethraliss
        challengeMapID = 250,
        mapID = 1877,
        LFGDungeonID = 1694,
        shortName = "TOS",
        portalSpellID = 1286828,
    },
    [399] = { -- Ruby Life Pools
        challengeMapID = 399,
        mapID = 2521,
        LFGDungeonID = 2360,
        shortName = "RLP",
        portalSpellID = 393256,
    },
    [584] = { -- The Blinding Vale
        challengeMapID = 584,
        mapID = 2859,
        LFGDungeonID = 3075,
        shortName = "BV",
        portalSpellID = 1286801,
    },
    [585] = { -- Voidscar Arena
        challengeMapID = 585,
        mapID = 2923,
        LFGDungeonID = 3106,
        shortName = "VSA",
        portalSpellID = 1286804,
    },
    [586] = { -- Den of Nalorakk
        challengeMapID = 586,
        mapID = 2825,
        LFGDungeonID = 3051,
        shortName = "DON",
        portalSpellID = 1286807,
    },
    [587] = { -- Murder Row
        challengeMapID = 587,
        mapID = 2813,
        LFGDungeonID = 3089,
        shortName = "MR",
        portalSpellID = 1286809,
    },
    [588] = { -- Altar of Fangs
        challengeMapID = 588,
        mapID = 2993,
        LFGDungeonID = 3190,
        shortName = "AOF",
        portalSpellID = 1286812,
    },
    ---AUTO_GENERATED TAILING DatabaseMythicPlus
}
