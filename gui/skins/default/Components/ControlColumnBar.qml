import QtQuick 1.1
import Components.Text 1.0


Item {
    id: bar

    width: 212
    height: 200

    // percentage of critical level where warning (yellow band) starts
    property real perc_warning: 0.8
    // value of critical level (red band)
    property int level_critical: 100
    // actual value to be rendered
    property int level_actual: 50
    // percentage of critical level that control must graphically span
    property real perc_graphic: 1.1
    // critical value bar is visible?
    property bool critical_bar_visible: true

    // helper property to know max graphically represented value
    property real max_graph_level: Math.max(level_critical * perc_graphic, level_actual)
    // value of critical level (calculated from percentage, but can be rebinded)
    property int level_warning: level_critical * perc_warning

    Rectangle {
        // a gray rectangle for the column
        id: bg
        anchors.fill: parent
        color: "gray"
        Rectangle {
            // the ok band (the green one)
            // it must stretch till the warning level
            // it must resize to fit the max graphical level
            id: band_ok
            color: "green"
            height: (level_actual < level_warning ? level_actual : level_warning) * parent.height / max_graph_level
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            // the warning band (the yellow one)
            // it appears if actual level is above the set threshold
            // it must stretch till the critical level
            // it must resize to fit the max graphical level
            id: band_warning
            color: "yellow"
            height: (level_actual < level_critical ? (level_actual > level_warning ? level_actual - level_warning : 0) : level_critical - level_warning) * parent.height / max_graph_level
            anchors {
                bottom: band_ok.top
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            // the critical band (the red one)
            // it must stretch to fit the max graphical level
            // it appears if actual level is above the critical threshold
            id: band_critical
            color: "red"
            height: (level_actual > level_critical ? level_actual - level_critical : 0) * parent.height / max_graph_level
            anchors {
                bottom: band_warning.top
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            // the critical value is rendered with a bar
            id: level
            color: "blue"
            height: critical_bar_visible ? 2 : 0
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: level_critical * parent.height / max_graph_level
            }
        }
        Item {
            // the zero label on the lower left corner of the column
            width: 40
            height: 20
            anchors {
                right: parent.left
                bottom: parent.bottom
            }
            Rectangle {
                color: "gray"
                opacity: 1
                radius: 4
                anchors {
                    fill: parent
                    centerIn: parent
                    margins: 2
                }
                UbuntuLightText {
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
            // the critical value label on the left side of the column
            width: 40
            height: 20
            anchors {
                right: parent.left
                bottom: parent.bottom
                bottomMargin: level_critical * parent.height / max_graph_level
            }
            Rectangle {
                color: "gray"
                opacity: 1
                radius: 4
                anchors {
                    fill: parent
                    centerIn: parent
                    margins: 2
                }
                UbuntuLightText {
                    text: level_critical
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
