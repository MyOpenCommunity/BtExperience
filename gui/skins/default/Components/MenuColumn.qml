import QtQuick 1.1

Item {
    id: element
    // Public functions

    // load of a sub-element
    function loadElement(fileName, title, model) {
        element.loadComponent(menuLevel, fileName, title, model)
    }

    // Close the element itself and its children
    function closeElement() {
        element.closeItem(menuLevel)
    }

    // Close the child's element (if present)
    function closeChild() {
        element.closeItem(menuLevel + 1)
    }

    Image {
        id: background
        source: "../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    // The signals captured from the MenuContainer to create/close child or the element
    // itself.
    signal closeItem(int menuLevel)
    signal loadComponent(int menuLevel, string fileName, string title, variant dataModel)

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

    Constants {
        id: constants
    }

    Behavior on x {
        enabled: element.enableAnimation
        NumberAnimation { id: defaultanimation; duration: constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    Behavior on opacity {
        enabled: element.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    BorderImage {
        id: name
        source: "../images/common/ombra1elemento.png"
        anchors.fill: parent
        border { left: 30; top: 30; right: 30; bottom: 30; }
        anchors { leftMargin: -25; topMargin: -25; rightMargin: -25; bottomMargin: -25 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }


    MouseArea {
        // When the user press a MenuItem during the effect shown at the creation
        // of the MenuColumn container, the pressed item is not displayed at
        // the same position of the normal one.
        // To prevent this weird graphical behaviour we block the events during
        // the effect.

        visible: defaultanimation.running
        anchors.fill: parent
        z: 10
    }

    property QtObject dataModel: null
}

