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
