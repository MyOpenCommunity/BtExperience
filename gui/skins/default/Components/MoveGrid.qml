// Implement a grid which can be used to move Items around the page.
// Used in Profile and RoomView.
import QtQuick 1.1

Item {
    id: bgMoveGrid

    property int maxItemWidth: 0
    property int maxItemHeight: 0
    property Item selectedItem: null

    property alias gridX: moveGrid.x
    property alias gridY: moveGrid.y
    property alias gridW: moveGrid.width
    property alias gridH: moveGrid.height

    signal moveEnd

    function moveTo(absX, absY) {
        // Map absolute coordinates to your item's coordinate system and set
        // them into selectedItem
        // Optionally, you can also trigger animations for the movement.
        console.log("Implement me.")
    }

    Rectangle {
        id: gridRect
        anchors {
            fill: parent
            leftMargin: bgMoveGrid.maxItemWidth / 2
            rightMargin: bgMoveGrid.maxItemWidth / 2
            topMargin: bgMoveGrid.maxItemHeight / 2
            bottomMargin: bgMoveGrid.maxItemHeight / 2
        }
        color: "black"
        opacity: 0.6
        visible: false
        radius: 10
    }

    Grid {
        id: moveGrid
        // TODO: do these need to be exposed?
        columns: 18
        rows: 14
        visible: false
        anchors {
            fill: parent
            leftMargin: bgMoveGrid.maxItemWidth / 2
            rightMargin: bgMoveGrid.maxItemWidth / 2
            topMargin: bgMoveGrid.maxItemHeight / 2
            bottomMargin: bgMoveGrid.maxItemHeight / 2
        }

        Repeater {
            model: moveGrid.columns * moveGrid.rows

            delegate: Item {
                width: moveGrid.width / moveGrid.columns
                height: moveGrid.height / moveGrid.rows

                BeepingMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // map the coordinates to the RoomItem's parent
                        var absPos = parent.mapToItem(null, x, y)
                        bgMoveGrid.moveTo(absPos.x - bgMoveGrid.maxItemWidth / 2, absPos.y - bgMoveGrid.maxItemHeight / 2)
                        bgMoveGrid.moveEnd()
                        bgMoveGrid.selectedItem = null
                    }
                }
            }

        }

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
    }

    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: moveGrid
                visible: true
            }
            PropertyChanges {
                target: gridRect
                visible: true

            }
        }
    ]
}
