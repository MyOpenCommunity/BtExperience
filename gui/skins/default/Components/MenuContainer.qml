import QtQuick 1.1
import "MenuContainer.js" as Script

// The MenuContainer components encapsulates some logic to show a gerarchic list
// of MenuColumn with different sizes and behaviour. The items are arranged
// horizontally inside the container until the sum of their width overtakes
// the width of the container. In this case, the first element (or elements) are
// hidden.
// Using the itemsLeftMargin you can control the spacing between the
// back button and the root element.
// Every item must emit the signal loadComponent to request the loading of a
// child element, or the closeItem to close it and can optionally implement the
// hooks onChildLoaded and onChildDestroyed.

Item {
    id: mainContainer
    width: 600
    height: 400

    // The spacing between the buttons on the left and the first column
    property int itemsLeftMargin: 20

    // the spacing between columns
    property int itemsSpacing: 0

    // The filename of the root element (without scroll, the first column)
    property string rootElement

    property QtObject rootData: null

    // the page where the container is placed
    property variant pageObject: undefined

    // the object that represents the root element (without scroll, the first column)
    property variant rootObject: undefined

    // the object that represents the current element (the last column open)
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

    Constants {
        id: constants
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
                NumberAnimation { id: defaultanimation; duration: constants.elementTransitionDuration }
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
                    PropertyAnimation { duration: constants.lineTransitionDuration }
                }

                Behavior on x {
                    enabled: line.enableAnimation
                    PropertyAnimation { duration: constants.lineTransitionDuration }
                }
            }
        }
    }

    Component.onCompleted: {
        Script.loadComponent(-1, mainContainer.rootElement, "", rootData)
    }
}


