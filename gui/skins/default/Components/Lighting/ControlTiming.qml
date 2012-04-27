import QtQuick 1.1

Image {
    id: control
    source: "../../images/common/bg_DueRegolazioni.png"
    width: 265
    height: 188
    property alias title: title.text

    Text {
        id: title
        color: "#000000"
        text: qsTr("timing")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }



    Row {
        anchors {
            top: title.bottom
            topMargin: 10
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        Image {
            source: "../../images/common/btn_annulla.png"
            width: parent.width / 2
            height: 24

            Text {
                text: qsTr("enabled")
                anchors.centerIn: parent
                font.capitalization: Font.SmallCaps
            }

            MouseArea {
                anchors.fill: parent
                onClicked: control.state = ""
            }
        }

        Image {
            source: "../../images/common/btn_annulla.png"
            width: parent.width / 2
            height: 24

            Text {
                text: qsTr("disabled")
                anchors.centerIn: parent
                font.capitalization: Font.SmallCaps
            }

            MouseArea {
                anchors.fill: parent
                onClicked: control.state = "disabled"
            }
        }
    }

    Row {
        id: timingRow
        width: control.width - 20 // margins
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        TimeButtons {
            id: timingHours
            width: (control.width - 20) / 3
            measureUnit: qsTr("hours")
            onPlusClicked: console.log("hour plus clicked")
            onMinusClicked: console.log("hour minus clicked")
        }
        TimeButtons {
            width: (control.width - 20) / 3
            measureUnit: qsTr("minutes")
        }
        TimeButtons {
            width: (control.width - 20) / 3
            measureUnit: qsTr("seconds")
        }
    }

    // the following two Texts put a colon ':' between the elements in timingRow
    // we need a formula to compute the x because the element may be resized
    Text {
        anchors.verticalCenter: timingRow.verticalCenter
        x: timingHours.x + timingHours.width + 7
        text: ":"
        color: "#5b5b5b"
        font.pointSize: 18
        font.bold: true
    }

    Text {
        anchors.verticalCenter: timingRow.verticalCenter
        x: timingHours.x + timingHours.width * 2 + 7
        text: ":"
        color: "#5b5b5b"
        font.pointSize: 18
        font.bold: true
    }

    Rectangle {
        id:darkRect
        z: 1
        anchors {
            top: timingRow.top
            bottom: parent.bottom
            bottomMargin: 10
            right: parent.right
            rightMargin: 10
            left: parent.left
            leftMargin: 10
        }

        color: "grey"
        opacity: 0

        MouseArea {
            anchors.fill: parent
        }
    }

    states: [
        State {
            name: "disabled"
            PropertyChanges {
                target: darkRect
                opacity: 0.6
            }
        }

    ]
}

