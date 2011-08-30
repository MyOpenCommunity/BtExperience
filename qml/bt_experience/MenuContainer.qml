import QtQuick 1.0
import "MenuContainer.js" as Script

// The MenuContainer components encapsulates some logic to show a gerarchic list
// of MenuElement with different sizes and behaviour. The items are arranged
// horizontally  inside the container until the sum of their width overtakes
// the width of the container. In this case, the first element (or elements) are
// hidden.
// Using the itemsLeftMargin you can control the spacing between the
// back button and the root element, while using the itemsSpacing you can control
// the spacing between items.
// Every item must emit the signal loadComponent(string fileName) to request
// the loading of a child, and can implement the hooks onChildLoaded and
// onChildDestroyed.

Item {
    id: container
    width: 600
    height: 400
    property int itemsLeftMargin: 20
    property int itemsSpacing: 0
    property string rootElement
    signal closed

    ButtonBack {
        id: backButton
        anchors.top: container.top
        anchors.left: container.left
        onClicked: Script.closeItem()
    }

    Component.onCompleted: {
        Script.loadComponent(-1, container.rootElement)
    }
}


