import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    Column {

    Item {
        width: bg.width
        height: bg.height

        SvgImage {
            id: bg
            source: "../../images/common/bg_comando.svg"
        }

        ButtonThreeStates {
            anchors.centerIn: parent
            defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
            pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
            selectedImage: "../../images/common/btn_apriporta_ok_on.svg"
            text: "start"
            onClicked: column.dataModel.start()
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
            text: column.dataModel.enabled ? qsTr("enabled") : qsTr("disabled")
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
            onClicked: column.dataModel.enabled = !column.dataModel.enabled
            status: !column.dataModel.enabled
        }
    }

    }
}
