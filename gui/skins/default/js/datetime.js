.pragma library


// returns a dict with date and time fields correctly formatted; the dateTime
// parameter is optional: if not passed in it formats now as date and time
function format(dateTime) {
    // checks if a dateTime was passed in and initializes dt
    var dt = typeof dateTime !== 'undefined' ? dateTime : new Date();
    // TODO read format information from configuration file?
    // returns a dict with date and time formatted
    return {"time": Qt.formatDateTime(dt, "hh:mm"), "date": Qt.formatDateTime(dt, "dd/MM/yyyy")}
}

function daysInMonth(month,year) {
    return new Date(year, month, 0).getDate()
}

// returns a date with month decremented by 1
function previousMonth(dateTime) {
    var month = dateTime.getMonth()
    if (month === 0) {
        dateTime.setFullYear(dateTime.getFullYear() - 1)
        dateTime.setMonth(11)
    }
    else {
        dateTime.setMonth(month -1)
    }
    return dateTime
}

// returns a date with month incremented by 1
function nextMonth(dateTime) {
    var month = dateTime.getMonth()
    if (month === 11) {
        dateTime.setFullYear(dateTime.getFullYear() + 1)
        dateTime.setMonth(0)
    }
    else {
        dateTime.setMonth(month + 1)
    }
    return dateTime
}

// returns a date with year decremented by 1
function previousYear(dateTime) {
    dateTime.setFullYear(dateTime.getFullYear() - 1)
    return dateTime
}

// returns a date with year incremented by 1
function nextYear(dateTime) {
    dateTime.setFullYear(dateTime.getFullYear() + 1)
    return dateTime
}

// returns a the number of days in a month
function daysInMonth(month, year) {
    return new Date(year, month + 1, 0).getDate()
}

// returns a date with day decremented by 1
function previousDay(dateTime) {
    if (dateTime.getDate() === 1) {
        dateTime = previousMonth(dateTime)
        dateTime.setDate(daysInMonth(dateTime.getMonth(), dateTime.getFullYear()))
    }
    else
        dateTime.setDate(dateTime.getDate() - 1)
    return dateTime
}

// returns a date with day incremented by 1
function nextDay(dateTime) {
    var day = dateTime.getDate() + 1
    if (day > daysInMonth(dateTime.getMonth(), dateTime.getFullYear())) {
        dateTime.setDate(1)
        return nextMonth(dateTime)
    }

    dateTime.setDate(dateTime.getDate() + 1)
    return dateTime
}

