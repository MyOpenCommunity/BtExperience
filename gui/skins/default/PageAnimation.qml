import QtQuick 1.1

// Interface for transition effects on Pages
// It exposes four animations which should be called in the pages hooks invoked
// by the Stack javascript manager.
// The page property must be set before calling one of the animations which use
// it as the target of the animation.
// pushIn: a new page is being pushed into the stack and will become visible
// pushOut: current page will be covered by a new page
// popOut: current page will be removed from stack and destroyed
// popIn: a page on stack will be shown
// animationCompleted(): must be called at animation end

Item {
    property Item page: null
    property int transitionDuration: 400
    signal animationCompleted

    property variant pushIn
    property variant pushOut
    property variant popIn
    property variant popOut
}
