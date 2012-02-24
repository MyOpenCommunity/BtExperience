// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

// Interface for transition effects on Pages
// pushInStart(): a new page is being pushed into the stack and will become visible
// pushOutStart(): current page will be covered by a new page
// popOutStart(): current page will be removed from stack and destroyed
// popInStart(): a page on stack will be shown
// animationCompleted(): must be called at animation end
Item {
    property Item page: undefined
    property int transition_duration: 400
    signal animationCompleted

    function pushInStart() {
    }

    function popInStart() {
    }

    function pushOutStart() {
    }

    function popOutStart() {
    }
}
