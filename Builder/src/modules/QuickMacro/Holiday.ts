import assert from 'node:assert';

import type { Task } from '../../task.ts';

interface HolidayTimetable {
    startDate: Temporal.ZonedDateTime,
    endDate: Temporal.ZonedDateTime,
}

const getTimetableOutput = ({ startDate, endDate }: HolidayTimetable) => {
    let text = '';
    text += `-- ${startDate.toString()}\n`;
    text += 'startDate = {\n';
    text += `    year = ${startDate.year.toString()},\n`;
    text += `    month = ${startDate.month.toString()},\n`;
    text += `    day = ${startDate.day.toString()},\n`;
    text += `    hour = ${startDate.hour.toString()},\n`;
    text += `    minute = ${startDate.minute.toString()},\n`;
    text += '},\n';
    text += `-- ${endDate.toString()}\n`;
    text += 'endDate = {\n';
    text += `    year = ${endDate.year.toString()},\n`;
    text += `    month = ${endDate.month.toString()},\n`;
    text += `    day = ${endDate.day.toString()},\n`;
    text += `    hour = ${endDate.hour.toString()},\n`;
    text += `    minute = ${endDate.minute.toString()},\n`;
    text += '},\n';

    return text;
};

const getClosestTimetable = (
    duration: number[],
    date: number[],
    calendarFlag: number[],
): HolidayTimetable | undefined => {
    const now = Temporal.Now.zonedDateTimeISO('Asia/Shanghai');

    let durationDelayHour = 0;
    let durationActiveHour = 0;
    for (let i = 0; i < duration.length; i += 1) {
        if (calendarFlag[i] === 0) {
            durationDelayHour += duration[i];
        } else if (calendarFlag[i] === 3) {
            durationActiveHour = duration[i];
            break;
        }
    }

    const durationDelay = Temporal.Duration.from({ hours: durationDelayHour });
    const durationActive = Temporal.Duration.from({ hours: durationActiveHour });

    const timetable = date.reduce<HolidayTimetable | undefined>((prev, curr) => {
        if (curr === 0) {
            return prev;
        }

        // eslint-disable-next-line no-bitwise
        const minute = curr & 0x3f;
        // eslint-disable-next-line no-bitwise
        const hour = (curr >> 6) & 0x1f;
        // const unknown = (curr >> 11) & 0x7;
        // eslint-disable-next-line no-bitwise
        const dayIndex = (curr >> 14) & 0x3f;
        // eslint-disable-next-line no-bitwise
        const monthIndex = (curr >> 20) & 0xf;
        // eslint-disable-next-line no-bitwise
        const year = (curr >> 24) & 0x3f;

        if (
            minute === 0x3f
            || hour === 0x1f
            || dayIndex === 0x3f
            || monthIndex === 0xf
        ) {
            return prev;
        }

        let startDate = Temporal.ZonedDateTime.from({
            timeZone: 'Asia/Shanghai',
            year: year === 0x3f ? now.year : (2000 + year),
            month: monthIndex + 1,
            day: dayIndex + 1,
            hour,
            minute,
        }).add(durationDelay);
        let endDate = startDate.add(durationActive);

        if (year === 0x3f && Temporal.ZonedDateTime.compare(endDate, now) === -1) {
            startDate = Temporal.ZonedDateTime.from({
                timeZone: 'Asia/Shanghai',
                year: now.year + 1,
                month: monthIndex + 1,
                day: dayIndex + 1,
                hour,
                minute,
            }).add(durationDelay);
            endDate = startDate.add(durationActive);
        }

        if (!prev) {
            return {
                startDate,
                endDate,
            };
        }

        if (
            Temporal.ZonedDateTime.compare(prev.endDate, now) === 1
            && Temporal.ZonedDateTime.compare(endDate, now) === -1
        ) {
            // prefer future events
            return prev;
        }

        if (Temporal.Duration.compare(
            now.until(prev.endDate),
            now.until(endDate),
        ) === -1) {
            // prefer the event that ends sooner
            return prev;
        }

        return {
            startDate,
            endDate,
        };
    }, undefined);

    return timetable;
};

const task: Task = {
    key: 'QuickMacroHoliday',
    version: 1,
    fileDataIDs: [
        996357, // dbfilesclient/holidays.db2
    ],
    localeFileDataIDs: [],
    handler: ([
        holidays,
    ]) => {
        const hallowsEndTimetables = holidays
            .getAllIDs()
            .map((id): HolidayTimetable | undefined => {
                const row = holidays.getRowData(id);
                const region = row?.Region as number;
                const holidayNameID = row?.HolidayNameID as number;
                const flags = row?.Flags as number;
                const duration = row?.Duration as number[];
                const date = row?.Date as number[];
                const calendarFlag = row?.CalendarFlag as number[];

                if (
                    (region !== 0 && region !== 24) // global or asia regions
                    || holidayNameID !== 16 // Hallow's End
                    // eslint-disable-next-line no-bitwise
                    || (flags & 0x2) === 0 // should show in calendar
                ) {
                    return undefined;
                }

                return getClosestTimetable(duration, date, calendarFlag);
            });

        assert(hallowsEndTimetables.length < 2, 'Multiple Hallow\'s End entries found');

        const hallowsEndTimetable = hallowsEndTimetables[0];
        assert(hallowsEndTimetable, 'Failed to find Hallow\'s End');

        return new Map<string, string>([
            [
                'HallowsEnd',
                getTimetableOutput(hallowsEndTimetable),
            ],
        ]);
    },
};

export default task;
