import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        controlPanel.status = 0
    }

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
            id: controlPanel
            upperLabel: qsTr("threshold 1")
            upperText: dataModel.thresholds[0] + " " + dataModel.currentUnit
            bottomLabel: qsTr("threshold 2")
            bottomText: dataModel.thresholds[1] + " " + dataModel.currentUnit
            onEditClicked: {
                column.loadColumn(panelComponent, dataModel.name, dataModel)
                status = status === 0 ? 1 : 0
            }

            Component {
                id: panelComponent
                SettingsEnergySetThresholdsPanel {

                }
            }

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


