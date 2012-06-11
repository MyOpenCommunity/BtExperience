import QtQuick 1.1
import Components.Text 1.0


Item {
    id: element

    property real value: 2250
    property real maxValue: 3000
    property string unit: "kWh"

    width: 180
    height: 100


    Rectangle {
        id: label

        color: "transparent"
        height: 30
        anchors {
            top: parent.top
            topMargin: 1
            left: parent.left
            leftMargin: 2
            right: parent.right
            rightMargin: 2
        }

        UbuntuLightText {
            id: txtLabel
            text: qsTr("yearly cumulative consumption")
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            color: "white"
            anchors {
                fill: parent
                centerIn: parent
            }
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: value

        color: "transparent"
        height: 15
        anchors {
            top: label.bottom
            topMargin: 1
            left: parent.left
            leftMargin: 2
            right: parent.right
            rightMargin: 2
        }

        UbuntuLightText {
            id: txtValue
            text: element.value
            font.pixelSize: 16
            font.bold: true
            color: "white"
            anchors {
                fill: parent
                leftMargin: levelBar.width < txtValue.paintedWidth ? 0 : levelBar.width - txtValue.paintedWidth
            }
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
    }

    Image {
        id: consumptionBg
        source: "../../images/common/bg_volume.png"
        height: 30
        anchors {
            top: value.bottom
            topMargin: 1
            left: parent.left
            leftMargin: 2
            right: parent.right
            rightMargin: 2
        }

        Rectangle {
            id: levelBar
            color: "green"
            width: consumptionBg.width * (element.value / element.maxValue)
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
        }

    }

    Rectangle {
        id: unit

        color: "transparent"
        height: 15
        anchors {
            top: consumptionBg.bottom
            topMargin: 4
            left: parent.left
            leftMargin: 2
            right: parent.right
            rightMargin: 2
        }

        UbuntuLightText {
            id: txtUnit
            text: element.unit
            font.pixelSize: 14
            font.bold: true
            color: "white"
            anchors {
                fill: parent
                centerIn: parent
            }
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
    }

    states: [
        State {
            name: "cumYear"
        },
        State {
            name: "cumMonth"
            PropertyChanges {
                target: txtLabel
                text: qsTr("monthly cumulative consumption")
            }
        },
        State {
            name: "cumDay"
            PropertyChanges {
                target: txtLabel
                text: qsTr("daily cumulative consumption")
            }
        },
        State {
            name: "avgYear"
            PropertyChanges {
                target: txtLabel
                text: qsTr("yearly average consumption")
            }
        },
        State {
            name: "avgMonth"
            PropertyChanges {
                target: txtLabel
                text: qsTr("monthly average consumption")
            }
        },
        State {
            name: "avgDay"
            PropertyChanges {
                target: txtLabel
                text: qsTr("daily average consumption")
            }
        }
    ]
}
