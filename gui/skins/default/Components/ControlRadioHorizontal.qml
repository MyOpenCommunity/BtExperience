import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: control

    property alias text: radioLabel.text
    property alias pixelSize: radioLabel.font.pixelSize
    property bool status: false

    signal pressed

    height: radioBg.height

    UbuntuLightText {
        id: radioLabel

        font.pixelSize: 14
        color: "white"

        anchors {
            left: parent.left
            verticalCenter: radioBg.verticalCenter
        }
        width: parent.width / 100 * 90
        elide: Text.ElideRight
    }

    SvgImage {
        id: radioBg

        anchors {
            top: parent.top
            right: parent.right
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
