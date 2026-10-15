import Smart from './modules/AutoButton/Smart.ts';
import MythicPlus from './modules/Database/MythicPlus.ts';
import AutoLogging from './modules/Misc/AutoLogging.ts';
import Consumables from './modules/QuickMacro/Consumables.ts';
import CorpseToy from './modules/QuickMacro/CorpseToy.ts';
import Hearthstone from './modules/QuickMacro/Hearthstone.ts';
import TempEnchantment from './modules/QuickMacro/TempEnchantment.ts';
import { executeTasks } from './task.ts';

import type { Task } from './task.ts';

const tasks: Task[] = [
    Smart,
    MythicPlus,
    AutoLogging,
    Consumables,
    CorpseToy,
    Hearthstone,
    TempEnchantment,
];

executeTasks(tasks, process.argv[2] === '--force')
    .catch((err: unknown) => {
        console.error(err);
        process.exit(1);
    });
