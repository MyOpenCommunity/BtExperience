import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    Column {
        SvgImage {
            source: "../../images/common/panel_switch.svg";

            UbuntuLightText {

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: parent.width / 100 * 4
                    right: switchThresholds.left
                    rightMargin: parent.width / 100 * 4
                }
                font.pixelSize: 13
                color: "white"
                text: qsTr("thresholds enabled")
                wrapMode: Text.WordWrap
            }

            Switch {
                id: switchThresholds
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: parent.width / 100 * 4
                }

                status: 0
            }
        }

        ControlSettings {
            upperLabel: qsTr("threshold 1")
            upperText: "2,20 kw"
            bottomLabel: qsTr("threshold 2")
            bottomText: "2,95 kw"
        }

        SvgImage {
            source: "../../images/common/panel_switch.svg";

            UbuntuLightText {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: parent.width / 100 * 4
                    right: switchAlerts.left
                    rightMargin: parent.width / 100 * 4
                }
                font.pixelSize: 13
                color: "white"
                text: qsTr("alerts enabled")
                wrapMode: Text.WordWrap
            }

            Switch {
                id: switchAlerts
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: parent.width / 100 * 4
                }

                status: 0
            }
        }

    }
}


