import QtQuick 1.1


Item {
    id: bar

    width: 55
    height: 200

    // bottom label
    property string label: "january"
    // percentage of critical level where warning (yellow band) starts
    property real percYellow: 0.8
    // value of critical level (red band)
    property int levelRed: 100
    // actual value to be rendered
    property int levelActual: 50
    // critical value bar is visible?
    property int lateralBarValue: 90
    // max representable value
    property int maxGraphLevel: 200

    // helpers
    property int levelYellow: levelRed * percYellow

    Column {
        anchors.fill: parent
        spacing: 1

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: parent.height - label.height

            Rectangle {
                // the green band
                id: bandGree
                color: "green"
                height: (levelActual < levelYellow ? levelActual : levelYellow) * parent.height / maxGraphLevel
                width: parent.width * 2 / 3
                anchors {
                    bottom: parent.bottom
                    //left: parent.left
                    //leftMargin: 1
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Rectangle {
                // the yellow band
                id: bandYellow
                color: "yellow"
                height: (levelActual < levelRed ? (levelActual > levelYellow ? levelActual - levelYellow : 0) : levelRed - levelYellow) * parent.height / maxGraphLevel
                width: parent.width * 2 / 3
                anchors {
                    bottom: bandGree.top
                    //left: parent.left
                    //leftMargin: 1
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Rectangle {
                // the red band
                id: bandRed
                color: "red"
                height: (levelActual > levelRed ? levelActual - levelRed : 0) * parent.height / maxGraphLevel
                width: parent.width * 2 / 3
                anchors {
                    bottom: bandYellow.top
                    //left: parent.left
                    //leftMargin: 1
                    horizontalCenter: parent.horizontalCenter
                }
            }

            // TODO: previous year consumption, should be visible only in
            // year visualization. Disabled for demo.
//            Rectangle {
//                // the side band
//                id: bandSide
//                color: "light gray"
//                height: lateralBarValue * parent.height / maxGraphLevel
//                width: parent.width * 1 / 5
//                anchors {
//                    bottom: parent.bottom
//                    left: bandRed.right
//                    leftMargin: 1
//                }
//            }
        }

        Rectangle {
            id: label
            // the label on the bottom
            color: "gray"
            opacity: 1
            radius: 4
            height: 20
            anchors {
                left: parent.left
                leftMargin: 1
                right: parent.right
                rightMargin: 1
            }
            Text {
                text: bar.label
                color: "white"
                font.pixelSize: 10
                anchors {
                    fill: parent
                    centerIn: parent
                    margins: 2
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
