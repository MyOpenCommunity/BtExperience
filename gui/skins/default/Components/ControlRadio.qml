import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Item {
    id: control

    property alias text: radioLabel.text
    property alias pixelSize: radioLabel.font.pixelSize
    property bool status: false

    signal pressed

    width: radioBg.width
    height: radioLabel.height + radioBg.height

    UbuntuLightText {
        id: radioLabel

        font.pixelSize: 17
        color: "white"

        anchors {
            top: parent.top
            horizontalCenter: radioBg.horizontalCenter
        }
    }

    SvgImage {
        id: radioBg

        anchors {
            left: parent.left
            top: radioLabel.bottom
            topMargin: 5
        }

        source: "../images/common/btn_giorni.svg"

        SvgImage {
            source: "../images/common/check_giorni_azioni.svg"
            visible: control.status
            anchors.centerIn: parent
        }
    }

    BeepingMouseArea {
        anchors.fill: parent
        onPressed: control.pressed()
    }
}
