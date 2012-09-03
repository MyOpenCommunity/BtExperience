import QtQuick 1.1
import Components.Text 1.0

SvgImage {
    id: control
    property alias text: textId.text
    property alias status: switchId.status
    signal clicked

    source: "../images/common/panel_212x50.svg";

    UbuntuLightText {
        id: textId
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: parent.width / 100 * 4
            right: switchId.left
            rightMargin: parent.width / 100 * 4
        }
        font.pixelSize: 13
        color: "white"
        wrapMode: Text.WordWrap
    }

    Switch {
        id: switchId
        bgImage: "../images/common/bg_cursore.svg"
        leftImageBg: "../images/common/btn_temporizzatore_abilitato.svg"
        leftImage: "../images/common/ico_temporizzatore_abilitato.svg"
        arrowImage: "../images/common/ico_sposta_dx.svg"
        rightImageBg: "../images/common/btn_temporizzatore_disabilitato.svg"
        rightImage: "../images/common/ico_temporizzatore_disabilitato.svg"
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: parent.width / 100 * 4
        }

        status: 0
        onClicked: control.clicked()
    }
}
