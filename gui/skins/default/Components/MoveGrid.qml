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

    Rectangle {
        id: gridRect
        anchors {
            fill: parent
            rightMargin: parent.gridRightMargin
            bottomMargin: parent.gridBottomMargin
        }
        color: "black"
        opacity: 0.6
        visible: false
        radius: 10

        Row {
            anchors.left: parent.left
            anchors.leftMargin: spacing
            anchors.top: parent.top
            height: parent.height
            Repeater {
                delegate: SvgImage {
                    height: parent.height
                    source: "../images/dashline.svg"
                    fillMode: Image.Tile
                }
                model: moveGrid.columns
            }
            spacing: (moveGrid.width / moveGrid.columns) - 2
        }

        Item {
            anchors.left: parent.left
            anchors.top: parent.top
            width: moveGrid.width
            height: moveGrid.height

            Repeater {
                model: moveGrid.rows - 1
                SvgImage {
                    width: 1
                    height: parent.width
                    rotation: 270
                    transformOrigin: Item.TopLeft
                    anchors.top: parent.top
                    anchors.topMargin: width + (moveGrid.height / moveGrid.rows) * (index + 1)
                    anchors.left: parent.left
                    source: "../images/dashline.svg"
                    fillMode: Image.Tile
                }
            }
        }
    }

    Grid {
        id: moveGrid
        // TODO: do these need to be exposed?
        columns: 18
        rows: 14
        visible: false
        anchors {
            fill: parent
            rightMargin: bgMoveGrid.gridRightMargin
            bottomMargin: bgMoveGrid.gridBottomMargin
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
                visible: true
            }
            PropertyChanges {
                target: gridRect
                visible: true

            }
        }
    ]
}
