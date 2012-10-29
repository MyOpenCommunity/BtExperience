// Implement an area which can be used to move Items around the page.
// Used in Profile and RoomView.
import QtQuick 1.1

Item {
    id: bgMoveArea

    property int maxItemWidth: 0
    property int maxItemHeight: 0
    property Item selectedItem: null

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
        id: moveArea
        visible: false
        anchors.fill: parent

        // The functions below ensure that the x or the y are inside the
        // movearea rect.
        function xInRect(startX) {
            var halfItemWidth = bgMoveArea.maxItemWidth / 2
            var destX = startX
            if (destX - halfItemWidth < 0)
                destX = halfItemWidth
            else if (destX + halfItemWidth > bgMoveArea.width)
                destX = bgMoveArea.width - halfItemWidth

            return destX
        }

        function yInRect(startY) {
            var halfItemHeight = bgMoveArea.maxItemHeight / 2
            var destY = startY
            if (destY - halfItemHeight < 0)
                destY = halfItemHeight
            else if (destY + halfItemHeight > bgMoveArea.height)
                destY = bgMoveArea.height - halfItemHeight

            return destY
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
                target: moveArea
                visible: true
            }
            PropertyChanges {
                target: darkRect
                visible: true

            }
        }
    ]
}
