import QtQuick 1.1

Item {
    id: column
    // Public functions

    // load of a sub-element
    function loadColumn(component, title, model, properties) {
        column.loadComponent(menuLevel, component, title, model, properties)
    }

    // Close the column itself and its children
    function closeColumn() {
        column.closeItem(menuLevel)
    }

    // Close the child's element (if present)
    function closeChild() {
        column.closeItem(menuLevel + 1)
    }

    // The signals captured from the MenuContainer to create/close child or the element
    // itself.
    signal closeItem(int menuLevel)
    signal columnClicked()
    signal loadComponent(int menuLevel, variant component, string title, variant dataModel, variant properties)

    // the page where the element is placed
    property variant pageObject: undefined

    // Signals emitted from the container

    // This signal is emitted from the MenuContainer when the requested child
    // is loaded (the child itself can be retrieved from the homonymous property)
    property Item child: null
    signal childLoaded

    // This signal is emitted from the MenuContainer when the child is destroyed
    signal childDestroyed

    // private stuff
    property int menuLevel: -1

    property bool enableAnimation: true
    property bool animationRunning: defaultanimation.running

    // menu navigation
    property string what: pageObject === undefined ? "" : pageObject.what

    // Needed to properly set the shadow (MenuShadow) size.
    width: childrenRect.width
    height: childrenRect.height

    Constants {
        id: constants
    }

    Behavior on x {
        enabled: column.enableAnimation
        NumberAnimation { id: defaultanimation; duration: constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    Behavior on opacity {
        enabled: column.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    property QtObject dataModel: null
}

