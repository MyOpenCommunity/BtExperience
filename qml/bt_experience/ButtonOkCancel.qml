import QtQuick 1.0
Row {
    id: button
    signal okClicked
    signal cancelClicked
    Image {
        source: "common/on_off.png"
        Text {
            text: qsTr("OK")
            font.family: semiBoldFont.name
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: button.okClicked()
        }
    }
    Image {
        source: "common/on_off.png"
        Text {
            text: qsTr("ANNULLA")
            font.family: semiBoldFont.name
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.cancelClicked()
        }
    }
}

