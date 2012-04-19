/**
  * A module containing the logic for EventManager.
  */

Qt.include("../js/logging.js")

// time of last meaningful event, used to activate the screensaver
var last = 0


// updates "manually" last
function updateLast() {
    var d = new Date()
    last = d.getTime()
}

// calculates if timeout is elapsed for screensaver activation
function elapsed(lastTimePress, timeout) {
    // computes elapsed time from last
    var d = new Date()
    var now = d.getTime()
    var elapsed = (now - last) / 1000;
    // elapsed time is the min of last event and last press
    if (elapsed > lastTimePress)
        elapsed = lastTimePress
    if (elapsed > timeout)
        return true
    return false
}
