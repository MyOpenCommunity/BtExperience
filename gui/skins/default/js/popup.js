/**
  * Function to manage all popup types with all the needed different logics.
  */


var _alarmPopups = []


/**
  * Adds an alarm to list of alarm popups
  *
  * Adds an alarm to the stack of alarm popups and returns the last one
  *
  * type: translated text of alarm type
  * zone: translated zone description
  * dateTime: already formatted string which reports time and date
  */
function addAlarmPopup(type, zone, dateTime) {
    var data = []

    data["_kind"] = "alarm"
    data["title"] = qsTr("Alarm!")

    data["line1"] = dateTime

    var msg = type
    msg += ": "
    msg += zone
    data["line2"] = msg

    data["line3"] = ""
    data["confirmText"] = qsTr("Confirm")
    data["dismissText"] = qsTr("Dismiss")

    _alarmPopups.push(data)

    return data
}

/**
  * Confirms the current popup.
  *
  * Confirms the current popup. Based on popup type navigates to the right
  * application page.
  */
function confirm() {
    // TODO to be implemented
}

/**
  * Dismisses the current popup.
  *
  * Dismisses the current popup. Based on popup type this may mean several things:
  *     - pass to the next popup of the same type
  *     - pass to first popup of different type
  *     - close popup page
  *
  * Returns data to show when a popup must be shown, otherwise returns undefined
  */
function dismiss() {
    if (_alarmPopups.length > 0) {
        _alarmPopups.pop()
        return _alarmPopups[_alarmPopups.length - 1]
    }
    return undefined
}
