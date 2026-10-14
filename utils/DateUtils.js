.pragma library

// True if both dates fall on the same calendar day (year/month/day), ignoring
// time-of-day.
function isSameDay(a, b) {
    return a.getFullYear() === b.getFullYear()
        && a.getMonth() === b.getMonth()
        && a.getDate() === b.getDate()
}

// Midnight of the Monday (ISO 8601, Monday-based weeks) of the week
// containing 'date'.
function startOfIsoWeek(date) {
    var result = new Date(date)
    result.setHours(0, 0, 0, 0)
    var dayNumber = (result.getDay() + 6) % 7 // JS getDay() is Sunday-based, shift to Monday-based
    result.setDate(result.getDate() - dayNumber)
    return result
}

// ISO 8601 week number (Monday-based weeks, week 1 contains the year's first
// Thursday).
function isoWeekNumber(date) {
    var target = new Date(date)
    target.setHours(0, 0, 0, 0)
    var dayNumber = (target.getDay() + 6) % 7
    target.setDate(target.getDate() - dayNumber + 3) // nearest Thursday
    var firstThursday = new Date(target.getFullYear(), 0, 4)
    var firstDayNumber = (firstThursday.getDay() + 6) % 7
    firstThursday.setDate(firstThursday.getDate() - firstDayNumber + 3)
    return 1 + Math.round((target.getTime() - firstThursday.getTime()) / (7 * 86400000))
}

// ISO 8601 week-year: the year the week "belongs to", which can differ from
// the calendar year of the week's Monday for the first/last week of a year
// (e.g. 30.12.2019 is in week 1 of 2020). Defined as the year of the
// Thursday within that week.
function isoWeekYear(date) {
    var target = new Date(date)
    target.setHours(0, 0, 0, 0)
    var dayNumber = (target.getDay() + 6) % 7
    target.setDate(target.getDate() - dayNumber + 3) // nearest Thursday
    return target.getFullYear()
}

// Returns the Monday (as a Date, time set to midnight) of ISO week number
// 'week' in ISO week-year 'isoYear'.
function mondayOfIsoWeek(isoYear, week) {
    var jan4 = new Date(isoYear, 0, 4)
    jan4.setHours(0, 0, 0, 0)
    var jan4DayNumber = (jan4.getDay() + 6) % 7 // Monday-based
    var week1Monday = new Date(jan4)
    week1Monday.setDate(jan4.getDate() - jan4DayNumber)
    var monday = new Date(week1Monday)
    monday.setDate(week1Monday.getDate() + (week - 1) * 7)
    return monday
}

// Number of ISO weeks in a given ISO week-year (52 or 53).
function isoWeeksInYear(isoYear) {
    var p = function(y) {
        return (y + Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400)) % 7
    }
    return (p(isoYear) === 4 || p(isoYear - 1) === 3) ? 53 : 52
}

// Parses "HH:mm" into minutes since midnight. Returns -1 for invalid input.
function timeStringToMinutes(str) {
    var match = /^(\d{1,2}):(\d{2})/.exec(str || "")
    if (!match)
        return -1
    var h = parseInt(match[1])
    var m = parseInt(match[2])
    if (h > 23 || m > 59)
        return -1
    return h * 60 + m
}

function minutesToTimeString(total) {
    var h = Math.floor(total / 60)
    var m = total % 60
    return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
}

var LAST_QUARTER_OF_DAY = 23 * 60 + 45

// Rounds an "HH:mm" string down to the previous full quarter hour.
// Invalid input is returned unchanged.
function floorToQuarter(str) {
    var total = timeStringToMinutes(str)
    if (total < 0)
        return str
    return minutesToTimeString(Math.floor(total / 15) * 15)
}

// Rounds an "HH:mm" string up to the next full quarter hour, capped at 23:45.
// Invalid input is returned unchanged.
function ceilToQuarter(str) {
    var total = timeStringToMinutes(str)
    if (total < 0)
        return str
    return minutesToTimeString(Math.min(Math.ceil(total / 15) * 15, LAST_QUARTER_OF_DAY))
}

// Normalizes a schedule entry to quarter hours (start rounded down, end rounded
// up). Returns {startTime, endTime} or null if the entry is invalid or empty
// (invalid format, or start >= end after rounding).
function normalizeQuarterRange(startStr, endStr) {
    if (timeStringToMinutes(startStr) < 0 || timeStringToMinutes(endStr) < 0)
        return null
    var start = floorToQuarter(startStr)
    var end = ceilToQuarter(endStr)
    if (timeStringToMinutes(start) >= timeStringToMinutes(end))
        return null
    return { startTime: start, endTime: end }
}
