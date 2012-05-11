/**
  * A module containing the logic for EventManager.
  */

Qt.include("../js/logging.js")

// calculates if timeout is elapsed for screensaver activation
function elapsed(lastTimePress, timeout) {
    return lastTimePress > timeout ? true : false
}
