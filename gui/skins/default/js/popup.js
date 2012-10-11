/**
  * Function to manage all popup types with all the needed different logics.
  */


var _alarmPopups = []
var _stopGoPopups = []
var _unreadMessagesPopups = []


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
    data["title"] = qsTr("ANTINTRUSION")

    data["line1"] = dateTime

    var msg = type
    msg += ": "
    msg += zone
    data["line2"] = msg

    data["line3"] = ""
    data["confirmText"] = qsTr("More info")
    data["dismissText"] = qsTr("Ignore")

    _alarmPopups.push(data)

    return _highestPriorityPopup()
}

/**
  * Adds a stop&go alarm to list of alarm popups
  *
  * Adds a stop&go alarm to the stack of alarm popups and returns the last one
  *
  * descr: translated text of stop&go description
  * status: enum that corresponds to the kind of alarm
  */
function addStopAndGoPopup(descr, status) {
    var data = []

    data["_kind"] = "stop&go"
    data["title"] = qsTr("SUPERVISION")

    data["line1"] = descr
    data["line2"] = status
    data["line3"] = ""

    data["confirmText"] = qsTr("Show")
    data["dismissText"] = qsTr("Ignore")

    _stopGoPopups.push(data)

    return _highestPriorityPopup()
}

/**
  * Updates the popup of unread messages
  *
  * Updates the popup of unread messages and returns if popup page must be
  * shown or hide.
  *
  * unreadMessages: actual number of unread messages; may be zero
  */
function updateUnreadMessages(unreadMessages) {
    // in this case we only show a message with the number of unread messages
    // we don't add messages every time, but update the only one message created
    // once for all
    var data = []

    data["_kind"] = "messages"
    data["title"] = qsTr("MESSAGES")

    data["line1"] = unreadMessages
    data["line2"] = qsTr("new messages")
    data["line3"] = ""

    data["confirmText"] = qsTr("Read")
    data["dismissText"] = qsTr("Ignore")

    if (unreadMessages === 0)
        data = undefined // no message to show

    if (_unreadMessagesPopups.length > 0)
        _unreadMessagesPopups[0] = data
    else
        _unreadMessagesPopups.push(data)

    return _highestPriorityPopup()
}

/**
  * Confirms the current popup.
  *
  * Confirms the current popup. Based on popup type navigates to the right
  * application page.
  *
  * Returns a string to navigate on the correct application page.
  */
function confirm() {
    var p = _alarmPopups.pop() // last popup gives me info on what to do next

    // resets all popups
    _alarmPopups = []
    _stopGoPopups = []
    _unreadMessagesPopups = []

    if (p["_kind"] === "messages") {
        return "Messages"
    }

    if (p["_kind"] === "alarm") {
        return "Antintrusion"
    }

    if (p["_kind"] === "stop&go") {
        return "Supervision"
    }

    return ""
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
        return _highestPriorityPopup()
    }

    if (_stopGoPopups.length > 0) {
        _stopGoPopups.pop()
        return _highestPriorityPopup()
    }

    if (_unreadMessagesPopups.length > 0) {
        _unreadMessagesPopups.pop()
        return _highestPriorityPopup()
    }

    return undefined
}

function _highestPriorityPopup() {
    // scans all lists to find the popup to show

    if (_alarmPopups.length > 0) {
        return _alarmPopups[_alarmPopups.length - 1]
    }

    if (_stopGoPopups.length > 0) {
        return _stopGoPopups[_stopGoPopups.length - 1]
    }

    if (_unreadMessagesPopups.length > 0) {
        return _unreadMessagesPopups[0] // only one exists
    }

    return undefined
}
