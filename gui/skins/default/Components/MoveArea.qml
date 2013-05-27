// Implement an area which can be used to move Items around the page.
// Used in Profile and RoomView.
import QtQuick 1.1

Item {
    id: bgMoveArea

    property Item selectedItem: null

    signal moveEnd

    function moveTo(absX, absY) {
        // Map absolute coordinates to your item's coordinate system and set
        // them into selectedItem
        // Optionally, you can also trigger animations for the movement.
        console.log("Implement me.")
    }

    // maps from absolute coordinates to area coordinates
    function absolute2area(absPt) {
        return bgMoveArea.mapFromItem(null, absPt.x, absPt.y)
    }

    // maps from area coordinates to absolute coordinates
    function area2absolute(areaPt) {
        return bgMoveArea.mapToItem(null, areaPt.x, areaPt.y)
    }

    // ensures an x coordinate inside this area
    function xInRect(startX, itemWidth) {
        var destX = startX
        if (destX < 0)
            destX = 0
        else if (destX > bgMoveArea.width - itemWidth)
            destX = bgMoveArea.width - itemWidth

        return destX
    }

    // ensures an y coordinate inside this area
    function yInRect(startY, itemHeight) {
        var destY = startY
        if (destY < 0)
            destY = 0
        else if (destY > bgMoveArea.height - itemHeight)
            destY = bgMoveArea.height - itemHeight

        return destY
    }

    // generates a random position inside this area (without considering item
    // size)
    function randomPosition() {
        var xx = Math.random() * bgMoveArea.width
        var yy = Math.random() * bgMoveArea.height
        return Qt.point(xx, yy)
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

        onClicked: {
            var absPos = parent.mapToItem(null, xInRect(mouse.x), yInRect(mouse.y))

            bgMoveArea.moveTo(absPos.x, absPos.y)
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
