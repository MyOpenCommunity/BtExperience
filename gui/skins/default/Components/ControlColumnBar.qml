import QtQuick 1.1


Item {
    id: bar

    width: 212
    height: 200

    property int level: 135

    property int level1: 50
    property int level2: 100
    property int level3: 150

    Rectangle {
        id: bg
        anchors {
            fill: parent
        }
        color: "gray"
        Rectangle {
            id: threshold1
            color: "green"
            width: parent.width
            height: level1
            anchors {
                bottom: parent.bottom
            }
        }
        Rectangle {
            id: threshold2
            color: "yellow"
            width: parent.width
            height: level2 - level1
            anchors {
                bottom: threshold1.top
            }
        }
        Rectangle {
            id: threshold3
            color: "red"
            width: parent.width
            height: level3 - level2
            anchors {
                bottom: threshold2.top
            }
        }
        Rectangle {
            id: level
            color: "black"
            width: parent.width
            height: 2
            y: parent.height - level
            anchors {
                left: parent.left
                right: parent.right
            }
        }
    }
}
