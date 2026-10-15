import assert from 'node:assert';

import { timesSeries } from 'async';

import { getMythicPlusStaticData } from '../../rio.ts';

import type { Task } from '../../task.ts';

interface Dungeon {
    challengeMapID: number,
    name: string,
    mapID: number,
    lfgDungeonID: number,
    shortName?: string,
    portalSpellID?: number
}

interface Expansion {
    name: string,
    dungeons: Dungeon[],
}

const overrideMapExpansion = new Map<number, number>([
    [1007, 4], // Scholomance
    [1001, 4], // Scarlet Halls
    [1004, 4], // Scarlet Monastery
    [2291, 8], // De Other Side
]);

const overridePortalSpell = new Map<number, number>([
    [1209, 159898], // Skyreach
    [1651, 373262], // Return to Karazhan
    [2830, 1237215], // Eco-Dome Al'dani
]);

const task: Task = {
    key: 'DatabaseMythicPlus',
    version: 6,
    fileDataIDs: [
        1729547, // dbfilesclient/uiexpansiondisplayinfo.db2
        1394440, // dbfilesclient/globalstrings.db2
        1139939, // dbfilesclient/spellcategories.db2
        1140089, // dbfilesclient/spell.db2
        1361033, // dbfilesclient/lfgdungeons.db2
        1349477, // dbfilesclient/map.db2
        801709, // dbfilesclient/mapchallengemode.db2
    ],
    localeFileDataIDs: [],
    handler: async ([
        expansions,
        globalStrings,
        spellCategories,
        spell,
        lfgDungeons,
        map,
        mapChallengeMode,
    ]) => {
        const expansionLength = expansions.getAllIDs().length;
        const expansionNameMap = new Map<number, string>();
        globalStrings.getAllIDs().forEach((id) => {
            const row = globalStrings.getRowData(id);
            const tag = row?.BaseTag;
            const text = row?.TagText_lang;
            if (typeof tag === 'string' && typeof text === 'string') {
                const match = /^EXPANSION_NAME(\d+)$/.exec(tag);
                if (match) {
                    const index = parseInt(match[1], 10);
                    expansionNameMap.set(index, text);
                }
            }
        });

        const expansionData: Expansion[] = [];
        for (let i = 0; i < expansionLength; i += 1) {
            const name = expansionNameMap.get(i);
            assert(name !== undefined, `No expansion name found for index ${i.toString()}`);

            expansionData.push({
                name,
                dungeons: [],
            });
        }

        const shortNames = new Map<number, string>();
        await timesSeries(expansionLength, async (i: number) => {
            const res = await getMythicPlusStaticData(i);
            if ('seasons' in res) {
                res.seasons.forEach((season) => {
                    season.dungeons.forEach(({ challenge_mode_id: id, short_name: shortName }) => {
                        shortNames.set(id, shortName);
                    });
                });
                res.dungeons.forEach(({ challenge_mode_id: id, short_name: shortName }) => {
                    shortNames.set(id, shortName);
                });
            }
        });

        const teleportSpells: number[] = [];
        spellCategories.getAllIDs().forEach((id) => {
            const row = spellCategories.getRowData(id);
            if (row?.Category === 1407) {
                const spellID = row.SpellID as number;
                teleportSpells.push(spellID);
            }
        });

        const destinationMap = new Map<string, number>(
            teleportSpells.map((spellID) => {
                const row = spell.getRowData(spellID);
                const name = row?.NameSubtext_lang;
                assert(typeof name === 'string', `Invalid name for spell ID ${spellID.toString()}`);

                return [name, spellID] as const;
            }),
        );

        const mapID2LFGDungeonID = new Map<number, number>(
            lfgDungeons
                .getAllIDs()
                .map((id) => {
                    const row = lfgDungeons.getRowData(id);
                    const mapID = row?.MapID as number;

                    return [mapID, id] as const;
                })
                .reverse(),
        );

        mapChallengeMode.getAllIDs().forEach((id) => {
            const row = mapChallengeMode.getRowData(id);
            const name = row?.Name_lang;
            const mapID = row?.MapID as number;
            assert(typeof name === 'string', `Invalid name for mapChallengeMode ID ${id.toString()}`);

            const mapRow = map.getRowData(mapID);
            const mapName = mapRow?.MapName_lang;
            const expansionID = overrideMapExpansion.get(mapID) ?? (mapRow?.ExpansionID as number);
            assert(typeof mapName === 'string', `Invalid mapName for map ID ${mapID.toString()}`);

            const lfgDungeonID = mapID2LFGDungeonID.get(mapID);
            assert(lfgDungeonID !== undefined, `No LFGDungeonID found for mapID ${mapID.toString()}`);

            const shortName = shortNames.get(id);
            const portalSpellID = overridePortalSpell.get(mapID) ?? destinationMap.get(mapName);

            expansionData[expansionID].dungeons.push({
                challengeMapID: id,
                name,
                mapID,
                lfgDungeonID,
                shortName,
                portalSpellID,
            });
        });

        const text = expansionData
            .filter(({ dungeons }) => dungeons.length > 0)
            .map(({ name: expansionName, dungeons }) => {
                const dungeonsText = dungeons
                    .map(({
                        challengeMapID,
                        name,
                        mapID,
                        lfgDungeonID,
                        shortName,
                        portalSpellID,
                    }) => {
                        let dungeonText = `[${challengeMapID.toString()}] = { -- ${name}\n`;

                        dungeonText += `    challengeMapID = ${challengeMapID.toString()},\n`;
                        dungeonText += `    mapID = ${mapID.toString()},\n`;
                        dungeonText += `    LFGDungeonID = ${lfgDungeonID.toString()},\n`;

                        if (shortName !== undefined) {
                            dungeonText += `    shortName = "${shortName}",\n`;
                        }

                        if (portalSpellID !== undefined) {
                            dungeonText += `    portalSpellID = ${portalSpellID.toString()},\n`;
                        }

                        dungeonText += '},';

                        return dungeonText;
                    })
                    .join('\n');

                return `-- ${expansionName}\n${dungeonsText}`;
            })
            .join('\n\n');

        return text;
    },
};

export default task;
