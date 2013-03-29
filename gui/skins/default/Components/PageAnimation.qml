import QtQuick 1.1


/**
  Interface for page transition effects.

  It exposes four animations triggered by the Stack javascript manager.

  The page property must be set before calling the animations.
  */
Item {
    /** the page used as target for the animations */
    property Item page: null
    /** the duration of the animation effects */
    property int transitionDuration: 10
    /** a new page is being pushed into the stack and will become visible */
    property variant pushIn
    /** current page will be covered by a new page */
    property variant pushOut
    /** a page on stack will be shown */
    property variant popIn
    /** current page will be removed from stack and destroyed */
    property variant popOut

    /** must be called at animation end */
    signal animationCompleted
}
