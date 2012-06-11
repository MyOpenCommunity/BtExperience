import QtQuick 1.1
Row {
    id: button
    signal okClicked
    signal cancelClicked
    Image {
        source: "../images/common/btn_OKAnnulla.png"
        UbuntuLightText {
            text: qsTr("ok")
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
        source: "../images/common/btn_OKAnnulla.png"
        UbuntuLightText {
            text: qsTr("cancel")
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

