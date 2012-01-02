import QtQuick 1.1
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
// the loading of a child element, and can implement the hooks onChildLoaded and
// onChildDestroyed.

Item {
    id: mainContainer
    width: 600
    height: 400
    property int itemsLeftMargin: 20
    property int itemsSpacing: 0
    property string rootElement
    property variant rootObject: undefined
    property variant currentObject: undefined

    signal closed

    Column {
        id: buttonsColumn
        width: backButton.width
        spacing: 10
        anchors.topMargin: 33
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.left: mainContainer.left

        ButtonBack {
            id: backButton
            onClicked: Script.closeLastItem()
        }

        ButtonSystems {
            onClicked: mainContainer.closed()
        }
    }


    Item {
        id: clippingContainer
        anchors.left: buttonsColumn.right
        anchors.leftMargin: itemsLeftMargin
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true

        Item {
            id: elementsContainer
            width: 0
            x: 0
            y: 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            property bool animationRunning: defaultanimation.running

            Behavior on x {
                id: animation
                NumberAnimation { id: defaultanimation; duration: 400 }
            }

            Loader {
                id: itemHighlighed
                z: 10
            }

            Rectangle {
                id: line
                color: "#f27021"
                height: 2
                width: 0
                y: 0
                property bool enableAnimation: true

                Behavior on width {
                    enabled: line.enableAnimation
                    PropertyAnimation { duration: 200; }
                }

                Behavior on x {
                    enabled: line.enableAnimation
                    PropertyAnimation { duration: 200; }
                }
            }
        }
    }

    Component.onCompleted: {
        Script.loadComponent(-1, mainContainer.rootElement, "", null)
    }

    function loadComponent(menuLevel, fileName, title, model) {
        Script.loadComponent(menuLevel, fileName, title, model)
    }

    function closeItem(menuLevel) {
        Script.closeItem(menuLevel)
    }
}


