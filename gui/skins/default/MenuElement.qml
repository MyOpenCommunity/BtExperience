import QtQuick 1.1
import "constants.js" as Constants

Item {
    id: element
    // Public functions

    // load of a sub-element
    function loadElement(fileName, title, model) {
        if (model === undefined)
            model = null
        containerObject.loadComponent(menuLevel, fileName, title, model)
    }

    // Close the element itself and its children
    function closeElement() {
        containerObject.closeItem(menuLevel)
    }

    // Close the child's element (if present)
    function closeChild() {
        containerObject.closeItem(menuLevel + 1)
    }

    // the page where the element is placed
    property variant pageObject: undefined

    // the container where the element is placed
    property variant containerObject: undefined

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

    Behavior on x {
        enabled: element.enableAnimation
        NumberAnimation { id: defaultanimation; duration: Constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    Behavior on opacity {
        enabled: element.enableAnimation
        NumberAnimation { duration: Constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    BorderImage {
        id: name
        source: "images/common/ombra1elemento.png"
        anchors.fill: parent
        border { left: 30; top: 30; right: 30; bottom: 30; }
        anchors { leftMargin: -25; topMargin: -25; rightMargin: -25; bottomMargin: -25 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

    property QtObject dataModel: null

}

