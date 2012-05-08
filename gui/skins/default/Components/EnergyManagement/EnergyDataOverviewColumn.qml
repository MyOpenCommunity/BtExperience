import QtQuick 1.1
import Components 1.0


Item {
    id: element

    property string title: "40 kWh"
    property string description: "electricity"
    property string footer: "Month (day 21/30)"
    property string source: "../../images/common/svg_bolt.zip"

    // properties to be passed to the ControlColumnBar component
    property real perc_warning: 0.8
    property int level_critical: 100
    property int level_actual: 40


    Rectangle {
        // the graphical button on top of the bar
        id: button
        height: 90
        color: "white"
        anchors {
            top: element.top
            left: element.left
            right: element.right
        }
        SvgImage {
            source: element.source
            width: 40
            height: 40
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }
        Text {
            text: element.description
            color: "black"
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 5
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea {
            anchors.fill: parent
        }
    }

    Item {
        // the title on top of the bar (below the graphical button)
        id: title
        height: 30
        anchors {
            top: button.bottom
            left: button.left
            right: button.right
        }
        Rectangle {
            // a rectangle used to make text more readable
            color: "gray"
            opacity: 1
            radius: 4
            height: 20
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                right: parent.right
            }
            Text {
                text: element.title
                color: "white"
                anchors {
                    fill: parent
                    centerIn: parent
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ControlColumnBar {
        id: graph
        height: 200
        anchors {
            top: title.bottom
            left: title.left
            right: title.right
        }
        perc_warning: element.perc_warning
        level_critical: element.level_critical
        level_actual: element.level_actual
    }

    Item {
        // a text below the bar
        id: footer
        height: 30
        anchors {
            top: graph.bottom
            left: graph.left
            right: graph.right
        }
        Rectangle {
            color: "gray"
            opacity: 1
            radius: 4
            height: 20
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                right: parent.right
            }
            Text {
                text: element.footer
                color: "white"
                anchors {
                    fill: parent
                    centerIn: parent
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
