import QtQuick 1.1
import "../js/MenuContainer.js" as Script

// The MenuContainer components encapsulates some logic to show a gerarchic list
// of MenuColumn with different sizes and behaviour. The items are arranged
// horizontally inside the container until the sum of their width overtakes
// the width of the container. In this case, the first element (or elements) are
// hidden.
// Every item must emit the signal loadComponent to request the loading of a
// child element, or the closeItem to close it and can optionally implement the
// hooks onChildLoaded and onChildDestroyed.

Item {
    id: mainContainer
    width: 600
    height: 400

    // The root element (without scroll, the first column)
    property QtObject rootColumn

    property QtObject rootData: null

    // the page where the container is placed
    property variant pageObject: undefined

    // the object that represents the root element (without scroll, the first column)
    property variant rootObject: undefined

    // the object that represents the current element (the last column open)
    property variant currentObject: undefined

    signal closed
    signal rootColumnClicked
    signal loadNextColumn // used for menu navigation, see navigation.js for further details

    function closeLastColumn() {
        Script.closeLastItem()
    }

    function closeAll() {
        Script.closeItem(1)
    }

    Constants {
        id: constants
    }


    // This property is explicitly set to false whenever any operation on columns
    // is requested. This way we filter all inputs on clippingContainer until
    // all pending operations are completed. This avoids the 'double click' bug
    // on different elements in the first column
    //
    // Consider it an implementation detail
    property bool interactive: true

    Item {
        id: clippingContainer
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
                    NumberAnimation { duration: constants.lineTransitionDuration }
                }

                Behavior on x {
                    enabled: line.enableAnimation
                    NumberAnimation { duration: constants.lineTransitionDuration }
                }
            }
        }

        MouseArea {
            id: interactivityArea
            anchors.fill: parent
            visible: !interactive
        }
    }

    Component.onCompleted: {
        Script.loadComponent(-1, mainContainer.rootColumn, "", rootData)
        mainContainer.rootObject.columnClicked.connect(rootColumnClicked)
        mainContainer.loadNextColumn() // primes the menu navigation, see navigation.js for further details
    }
}


