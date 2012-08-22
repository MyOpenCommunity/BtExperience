// Implement a grid which can be used to move Items around the page.
// Used in Profile and RoomView.
import QtQuick 1.1

Item {
    id: bgMoveGrid

    property int gridRightMargin: 0
    property int gridBottomMargin: 0
    property Item selectedItem: null

    signal moveEnd

    function moveTo(absX, absY) {
        // Map absolute coordinates to your item's coordinate system and set
        // them into selectedItem
        // Optionally, you can also trigger animations for the movement.
        console.log("Implement me.")
    }

    Grid {
        id: moveGrid
        // TODO: do these need to be exposed?
        columns: 18
        rows: 14
        opacity: 0
        anchors {
            fill: parent
            rightMargin: bgMoveGrid.gridRightMargin
            bottomMargin: bgMoveGrid.gridBottomMargin
        }

        Repeater {
            model: moveGrid.columns * moveGrid.rows

            delegate: Rectangle {
                id: rectDelegate
                color: "transparent"
                width: moveGrid.width / moveGrid.columns
                height: moveGrid.height / moveGrid.rows
                border {
                    width: 1
                    color: "cyan"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // map the coordinates to the RoomItem's parent
                        var absPos = parent.mapToItem(null, x, y)
                        bgMoveGrid.moveTo(absPos.x, absPos.y)
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
                opacity: 1
            }
        }
    ]
}
