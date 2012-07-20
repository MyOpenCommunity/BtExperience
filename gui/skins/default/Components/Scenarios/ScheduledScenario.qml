import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    Column {
    ControlOnOff {
        id: button
        onText: qsTr("start")
        offText: qsTr("stop")
        onClicked: {
            if (newStatus)
                column.dataModel.start()
            else
                column.dataModel.stop()
        }
    }

    SvgImage {
        source: "../../images/common/panel_212x50.svg"
        UbuntuLightText {
            id: timing

            anchors {
                verticalCenter: enableControl.verticalCenter
                left: parent.left
                leftMargin: 7
            }
            font.pixelSize: 14
            color: "white"
            text: qsTr("enabled")
        }

        Switch {
            id: enableControl
            bgImage: "../../images/common/bg_cursore.svg"
            leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
            leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
            arrowImage: "../../images/common/ico_sposta_dx.svg"
            rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
            rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 7
            }
        }
    }

    }
}
