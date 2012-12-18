import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    property alias text: caption.text

    source: "../../images/common/panel_212x50.svg"

    SvgImage {
        anchors.centerIn: parent
        source: "../../images/termo/temperatura/bg_temperatura_misurata.svg"

        UbuntuLightText {
            id: caption
            anchors.centerIn: parent
            font.pixelSize: 24
        }
    }
}

