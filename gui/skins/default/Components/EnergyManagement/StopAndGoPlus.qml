import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: element

    Column {
        SvgImage {
            source: "../../images/common/bg_panel_212x100.svg"

            UbuntuLightText {
                id: firstLine
                text: qsTr("reset")
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 8
                    left: parent.left
                    leftMargin: parent.width / 100 * 5
                }
            }

            UbuntuLightText {
                text: element.dataModel.autoReset ? qsTr("enabled") : qsTr("disabled")
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors {
                    top: firstLine.bottom
                    topMargin: parent.height / 100 * 2
                    left: parent.left
                    leftMargin: parent.width / 100 * 5
                }
            }

            Switch {
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                status: !element.dataModel.autoReset
                anchors {
                    top: firstLine.top
                    topMargin: parent.height / 100 * 5
                    right: parent.right
                    rightMargin: width / 100 * 8
                }
                onClicked: element.dataModel.autoReset = !element.dataModel.autoReset
            }

            ButtonThreeStates {
                id: buttonForce

                defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
                pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
                shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
                text: qsTr("reset")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
                onClicked: element.dataModel.forceClosed()
                anchors {
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 7
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }

        SvgImage {
            source: "../../images/common/bg_on-off.svg"

            UbuntuLightText {
                text: qsTr("check")
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 15
                    left: parent.left
                    leftMargin: parent.width / 100 * 5
                }
            }

            UbuntuLightText {
                text: element.dataModel.diagnostic ? qsTr("enabled") : qsTr("disabled")
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors {
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 15
                    left: parent.left
                    leftMargin: parent.width / 100 * 5
                }
            }

            Switch {
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                status: !element.dataModel.diagnostic
                anchors {
                    right: parent.right
                    rightMargin: width / 100 * 8
                    verticalCenter: parent.verticalCenter
                }
                onClicked: element.dataModel.diagnostic = !element.dataModel.diagnostic
            }
        }
    }
}
