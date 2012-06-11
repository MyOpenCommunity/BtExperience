import QtQuick 1.1


Item {
    id: element

    width: 180
    height: 60

    property string timepoint: "2011"

    signal plusClicked
    signal minusClicked

    Rectangle {
        id: period

        color: "light gray"
        radius: 4
        width: parent.width * 2.9 / 5
        anchors {
            top: parent.top
            topMargin: 1
            bottom: parent.bottom
            bottomMargin: 1
            left: left.right
            leftMargin: 2
            right: right.left
            rightMargin: 2
        }

        UbuntuLightText {
            id: timeperiod
            text: qsTr("year")
            font.pointSize: 10
            color: "black"
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        UbuntuLightText {
            text: element.timepoint
            font.pointSize: 14
            color: "black"
            anchors {
                bottom: parent.bottom
                bottomMargin: 6
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: left

        color: "light gray"
        radius: 4
        width: parent.width / 5
        anchors {
            top: parent.top
            topMargin: 1
            bottom: parent.bottom
            bottomMargin: 1
            left: parent.left
            leftMargin: 1
        }

        UbuntuLightText {
            text: "<"
            color: "black"
            anchors {
                fill: parent
                centerIn: parent
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            MouseArea {
                anchors.fill: parent
                onClicked: element.minusClicked()
            }
        }
    }

    Rectangle {
        id: right

        color: "light gray"
        radius: 4
        width: parent.width / 5
        anchors {
            top: parent.top
            topMargin: 1
            bottom: parent.bottom
            bottomMargin: 1
            right: parent.right
            rightMargin: 1
        }

        UbuntuLightText {
            text: ">"
            color: "black"
            anchors {
                fill: parent
                centerIn: parent
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            MouseArea {
                anchors.fill: parent
                onClicked: element.plusClicked()
            }
        }
    }

    states: [
        State {
            name: "year"
        },
        State {
            name: "month"

            PropertyChanges {
                target: timeperiod
                text: qsTr("month")
            }
        },
        State {
            name: "day"

            PropertyChanges {
                target: timeperiod
                text: qsTr("day")
            }
        }
    ]
}
