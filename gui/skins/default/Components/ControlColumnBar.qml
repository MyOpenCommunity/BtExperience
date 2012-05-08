import QtQuick 1.1


Item {
    id: bar

    width: 212
    height: 200

    property int actual: 180

    // assumes reference >= level2 >= level1, but doesn't check
    property int level1: 50
    property int level2: 100
    property real reference: 200.0 // the value that corresponds to 100%
    property real ratio: height / Math.max(actual, reference)

    Rectangle {
        id: bg
        anchors {
            fill: parent
        }
        color: "gray"
        Rectangle {
            id: threshold1
            color: "green"
            height: (actual < level1 ? actual : level1) * ratio
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            id: threshold2
            color: "yellow"
            height: (actual < level2 ? (actual > level1 ? actual - level1 : 0) : level2 - level1) * ratio
            anchors {
                bottom: threshold1.top
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            id: threshold3
            color: "red"
            height: (actual > level2 ? actual - level2 : 0) * ratio
            anchors {
                bottom: threshold2.top
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            id: level
            color: "blue"
            height: actual < parent.height ? 2 : 0
            y: parent.y + parent.height - level2 * ratio
            anchors {
                left: parent.left
                right: parent.right
            }
        }
        Item {
            x: parent.x
            y: parent.y + (actual * ratio < 20 ? parent.height - actual * ratio - 15 : parent.height - actual * ratio + 1)
            width: parent.width
            height: 15
            Text {
                text: actual
                color: "black"
                anchors {
                    fill: parent
                    centerIn: parent
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Item {
            y: parent.y + parent.height - 15
            width: 40
            height: 20
            anchors.right: parent.left
            Rectangle {
                color: "gray"
                opacity: 1
                radius: 4
                anchors {
                    fill: parent
                    centerIn: parent
                    margins: 2
                }
                Text {
                    text: "0"
                    color: "white"
                    anchors {
                        fill: parent
                        centerIn: parent
                        bottomMargin: 2
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Item {
            y: parent.y + parent.height - level2 * ratio
            width: 40
            height: 20
            anchors.right: parent.left
            Rectangle {
                color: "gray"
                opacity: 1
                radius: 4
                anchors {
                    fill: parent
                    centerIn: parent
                    margins: 2
                }
                Text {
                    text: level2
                    color: "white"
                    anchors {
                        fill: parent
                        centerIn: parent
                        bottomMargin: 2
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
