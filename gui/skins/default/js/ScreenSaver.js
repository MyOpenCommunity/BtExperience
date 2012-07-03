.pragma library // needed to have a unique last variable

/**
  * Logic for screensaver timeout management.
  *
  * For screensaver timeout there are two possible scenarios:
  *     1) the user interacts with the application
  *     2) an internal application event causes the timeout to reset
  *
  * Case #1 is managed by lastTimePress (is computed by C++ layer and
  *     passed to elapsed function)
  * Case #2 cannot be mananged in C++ layer, so an updateLast function is needed
  *
  * The updateLast function must be called inside QML layer whenever the timeout
  * must be reset.
  * An example scenario may be the following:
  *     1) the screensaver is active
  *     2) an alarm arrives
  *     3) the screensaver must disappear to make the user see the alarm
  *     4) if user doesn't take action, the screensaver must reactivate as soon
  *         as the timeout elapses
  *
  * in such a case, when the alarm arrives, we must call the updateLast function
  * so the scenario described is automatically managed.
  *
  */

// time of last meaningful event, used to activate the screensaver
var last = 0


// updates "manually" last
function updateLast() {
    var d = new Date()
    last = d.getTime()
}

// calculates if timeout is elapsed for screensaver activation
// please note that lastTimePress is optional: if not passed in, function
// considers only internal events
function elapsed(timeout, lastTimePress) {
    // calculates elapsed time from last
    var d = new Date()
    var now = d.getTime()
    var elapsed = (now - last) / 1000
    // elapsed time is the min of last event and last press (if defined)
    if (typeof lastTimePress !== 'undefined')
        if (elapsed > lastTimePress)
            elapsed = lastTimePress
    if (elapsed > timeout)
        return true
    return false
}
