import QtQuick 1.1

Item {
    id: element
    // Public functions

    // load of a sub-element
    function loadElement(fileName, title, model) {
        if (model === undefined)
            model = null
        mainContainer.loadComponent(menuLevel, fileName, title, model)
    }

    // Close the element itself and its children
    function closeElement() {
        mainContainer.closeItem(menuLevel)
    }

    // Close the child's element (if present)
    function closeChild() {
        mainContainer.closeItem(menuLevel + 1)
    }


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
        NumberAnimation { id: defaultanimation; duration: 400; easing.type: Easing.InSine }
    }

    Behavior on opacity {
        enabled: element.enableAnimation
        NumberAnimation { duration: 400; easing.type: Easing.InSine }
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

