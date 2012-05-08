import QtQuick 1.1
import Components 1.0


Item {
    id: element

    property int actual: 40

    // assumes level2 >= level1, but doesn't check
    property int level1: 50
    property int level2: 100
    property int reference: height
    property string title: "kWh"
    property string description: "electricity"
    property string footer: "Month (day 21/30)"
    property string source: "../../images/common/svg_bolt.zip"


    Rectangle {
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
    }

    Item {
        id: title
        height: 30
        anchors {
            top: button.bottom
            left: button.left
            right: button.right
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
        actual: element.actual
        level1: element.level1
        level2: element.level2
        reference: element.reference
    }

    Item {
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
