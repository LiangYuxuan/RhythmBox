import assert from 'node:assert';

import type { Task } from '../../task.ts';

interface Item {
    id: number,
    name: string,
    value: number,
}

interface Expansion {
    name: string,
    items: Item[],
}

const task: Task = {
    key: 'ProfessionKnowledgeItem',
    version: 1,
    fileDataIDs: [
        1729547, // dbfilesclient/uiexpansiondisplayinfo.db2
        1394440, // dbfilesclient/globalstrings.db2
        1572924, // dbfilesclient/itemsparse.db2
    ],
    localeFileDataIDs: [],
    handler: async ([
        expansions,
        globalStrings,
        itemSparse,
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
                items: [],
            });
        }

        itemSparse.getAllIDs().forEach((id) => {
            const row = itemSparse.getRowData(id);
            const expansionID = row?.ExpansionID as number;
            const display = row?.Display_lang;
            assert(typeof display === 'string', `Invalid name for item ID ${id.toString()}`);

            if ((display.startsWith('Flicker of ') || display.startsWith('Glimmer of ')) && display.endsWith(' Knowledge')) {
                expansionData[expansionID]?.items.push({
                    id,
                    name: display,
                    value: display.startsWith('Flicker of ') ? 1 : 2,
                });
            }
        });

        const outputText = expansionData
            .filter((expansion) => expansion.items.length > 0)
            .map((expansion) => {
                const text = `-- ${expansion.name}`;
                const itemsText = expansion.items
                    .map((item) => `[${item.id.toString()}] = ${item.value.toString()}, -- ${item.name}`)
                    .join('\n');
                return `${text}\n${itemsText}`;
            })
            .join('\n');

        return outputText;
    },
};

export default task;
