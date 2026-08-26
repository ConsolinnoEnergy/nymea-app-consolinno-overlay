.pragma library

// ISO 8601 week number (Monday-based weeks, week 1 contains the year's first
// Thursday). Kept in sync with the (private) copy in CoPeriodSelector.qml -
// duplicated rather than shared since that one lives inside a QtObject not
// meant for external reuse.
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
