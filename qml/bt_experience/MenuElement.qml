import QtQuick 1.1

Item {
    id: element
    // Signals that the element can emit

    // request the loading of a child
    signal loadChild(string childTitle, string fileName)

    // request to close the element itself and its children
    signal closeElement

    // request to close the child's element (if present)
    signal closeChild

    // Signals emitted from the container

    // This signal is emitted from the MenuContainer when the requested child
    // is loaded (the child itself can be retrieved from the homonymous property)
    property Item child: null
    signal childLoaded

    // This signal is emitted from the MenuContainer when the child is destroyed
    signal childDestroyed

    // private stuff
    property int menuLevel: -1
    signal _loadComponent(int menuLevel, string childTitle, string fileName)
    onLoadChild: _loadComponent(menuLevel, childTitle, fileName)

    signal _closeElement(int menuLevel)
    onCloseElement: _closeElement(menuLevel)

    onCloseChild: _closeElement(menuLevel + 1)

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

    onChildLoaded: {
        child.animationRunningChanged.connect(childAnimationHandler)
    }

    signal childAnimation(bool running)

    function childAnimationHandler()
    {
        if (child)
            childAnimation(child.animationRunning === true)
    }

    BorderImage {
        id: name
        source: "common/ombra1elemento.png"
        anchors.fill: parent
        border { left: 30; top: 30; right: 30; bottom: 30; }
        anchors { leftMargin: -25; topMargin: -25; rightMargin: -25; bottomMargin: -25 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

}

