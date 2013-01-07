import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: control

    property alias text: radioLabel.text
    property bool status: false

    signal clicked

    width: radioBg.width + radioLabel.width
    height: radioBg.height

    UbuntuLightText {
        id: radioLabel

        font.pixelSize: 14
        color: "white"

        anchors {
            left: parent.left
            bottom: radioBg.bottom
            verticalCenter: radioBg.verticalCenter
        }
    }

    SvgImage {
        id: radioBg

        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        source: "../images/common/btn_giorni.svg"

        SvgImage {
            source: "../images/common/check_giorni_azioni.svg"
            visible: control.status
            anchors.centerIn: parent
        }

        BeepingMouseArea {
            anchors.centerIn: parent
            width: parent.width + (parent.width / 100 * 3.3)
            height: parent.height + (parent.height / 100 * 3.3)
            onClicked: control.clicked()
        }
    }
}
