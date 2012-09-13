import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Item {
    id: control
    property alias text: radioLabel.text
    property bool status: false
    signal clicked

    width: radioBg.width
    height: radioLabel.height + radioBg.height

    UbuntuLightText {
        id: radioLabel
        font.pixelSize: 17
        color: "white"

        anchors.top: parent.top
        anchors.horizontalCenter: radioBg.horizontalCenter
    }

    SvgImage {
        id: radioBg
        anchors.left: parent.left
        anchors.top: radioLabel.bottom
        anchors.topMargin: 5
        source: "../images/common/btn_giorni.svg"

        SvgImage {
            source: "../images/common/check_giorni_azioni.svg"
            visible: control.status
            anchors.centerIn: parent
        }

        BeepingMouseArea {
            anchors.fill: parent
            onClicked: control.clicked()
        }
    }

}
