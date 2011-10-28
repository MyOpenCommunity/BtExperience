import QtQuick 1.1
Row {
    id: button
    signal okClicked
    signal cancelClicked
    Image {
        source: "common/btn_OKAnnulla.png"
        width: 104
        height: 50
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
        source: "common/btn_OKAnnulla.png"
        width: 104
        height: 50
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

