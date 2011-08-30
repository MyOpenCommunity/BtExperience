import QtQuick 1.0

Item {
    // Emit this signal to request the loading of a child
    signal loadChild(string childTitle, string fileName)

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

//    Behavior on x {
//        NumberAnimation { duration: 500 }
//    }
}

