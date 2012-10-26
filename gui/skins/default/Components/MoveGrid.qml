// Implement a grid which can be used to move Items around the page.
// Used in Profile and RoomView.
import QtQuick 1.1

Item {
    id: bgMoveArea

    property int maxItemWidth: 0
    property int maxItemHeight: 0
    property Item selectedItem: null

    property alias gridX: bgMoveArea.x
    property alias gridY: bgMoveArea.y
    property alias gridW: bgMoveArea.width
    property alias gridH: bgMoveArea.height

    signal moveEnd

    function moveTo(absX, absY) {
        // Map absolute coordinates to your item's coordinate system and set
        // them into selectedItem
        // Optionally, you can also trigger animations for the movement.
        console.log("Implement me.")
    }

    Rectangle {
        id: darkRect
        anchors {
            fill: parent
        }
        color: "black"
        opacity: 0.6
        visible: false
        radius: 10
    }

    BeepingMouseArea {
        id: moveGrid
        visible: false
        anchors.fill: parent

        // The functions below ensure that the x or the y are inside the
        // movearea rect.
        function xInRect(start_x) {
            var half_item_width = bgMoveArea.maxItemWidth / 2
            var dest_x = start_x
            if (dest_x - bgMoveArea.maxItemWidth / 2 < 0)
                dest_x = bgMoveArea.maxItemWidth / 2
            else if (dest_x + bgMoveArea.maxItemWidth / 2 > bgMoveArea.width)
                dest_x = bgMoveArea.width - bgMoveArea.maxItemWidth / 2

            return dest_x
        }

        function yInRect(start_y) {
            var half_item_height = bgMoveArea.maxItemHeight / 2
            var dest_y = start_y
            if (dest_y - bgMoveArea.maxItemHeight / 2 < 0)
                dest_y = bgMoveArea.maxItemHeight / 2
            else if (dest_y + bgMoveArea.maxItemHeight / 2 > bgMoveArea.height)
                dest_y = bgMoveArea.height - bgMoveArea.maxItemHeight / 2

            return dest_y
        }

        onClicked: {
            var absPos = parent.mapToItem(null, xInRect(mouse.x), yInRect(mouse.y))

            bgMoveArea.moveTo(absPos.x - bgMoveArea.maxItemWidth / 2, absPos.y - bgMoveArea.maxItemHeight / 2)
            bgMoveArea.moveEnd()
            bgMoveArea.selectedItem = null
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }


    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: moveGrid
                visible: true
            }
            PropertyChanges {
                target: darkRect
                visible: true

            }
        }
    ]
}
