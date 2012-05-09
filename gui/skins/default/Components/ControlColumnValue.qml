import QtQuick 1.1


Item {
    id: bar

    width: 55
    height: 200

    // bottom label
    property string label: "january"
    // percentage of critical level where warning (yellow band) starts
    property real perc_yellow: 0.8
    // value of critical level (red band)
    property int level_red: 100
    // actual value to be rendered
    property int level_actual: 50
    // critical value bar is visible?
    property int lateral_bar_value: 90
    // max representable value
    property int max_graph_level: 200

    // helpers
    property int level_yellow: level_red * perc_yellow

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
                id: band_green
                color: "green"
                height: (level_actual < level_yellow ? level_actual : level_yellow) * parent.height / max_graph_level
                width: parent.width * 2 / 3
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    leftMargin: 1
                }
            }

            Rectangle {
                // the yellow band
                id: band_yellow
                color: "yellow"
                height: (level_actual < level_red ? (level_actual > level_yellow ? level_actual - level_yellow : 0) : level_red - level_yellow) * parent.height / max_graph_level
                width: parent.width * 2 / 3
                anchors {
                    bottom: band_green.top
                    left: parent.left
                    leftMargin: 1
                }
            }

            Rectangle {
                // the red band
                id: band_red
                color: "red"
                height: (level_actual > level_red ? level_actual - level_red : 0) * parent.height / max_graph_level
                width: parent.width * 2 / 3
                anchors {
                    bottom: band_yellow.top
                    left: parent.left
                    leftMargin: 1
                }
            }

            Rectangle {
                // the side band
                id: band_side
                color: "light gray"
                height: lateral_bar_value * parent.height / max_graph_level
                width: parent.width * 1 / 5
                anchors {
                    bottom: parent.bottom
                    left: band_red.right
                    leftMargin: 1
                }
            }
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
