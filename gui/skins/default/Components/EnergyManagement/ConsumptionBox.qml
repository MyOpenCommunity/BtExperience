import QtQuick 1.1


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

        Text {
            id: txtLabel
            text: qsTr("yearly cumulative consumption")
            wrapMode: Text.WordWrap
            font.pointSize: 10
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

        Text {
            id: txtValue
            text: element.value
            font.pointSize: 11
            font.bold: true
            color: "white"
            anchors {
                fill: parent
                leftMargin: (barGreen.width - rectRemaining.width) < paintedWidth ? 0 : (barGreen.width - rectRemaining.width - paintedWidth)
            }
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: barGreen

        color: "green"
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
            id: rectRemaining
            color: "light gray"
            width: barGreen.width * (1.0 - element.value / element.maxValue)
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
        }
    }

    Rectangle {
        id: unit

        color: "transparent"
        height: 15
        anchors {
            top: barGreen.bottom
            topMargin: 1
            left: parent.left
            leftMargin: 2
            right: parent.right
            rightMargin: 2
        }

        Text {
            id: txtUnit
            text: element.unit
            font.pointSize: 10
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
