import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: element

    Column {
        SvgImage {
            source: "../../images/common/bg_on-off.svg"

            UbuntuLightText {
                text: qsTr("reset")
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
                text: element.dataModel.autoReset ? qsTr("enabled") : qsTr("disabled")
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
                status: !element.dataModel.autoReset
                anchors {
                    right: parent.right
                    rightMargin: width / 100 * 8
                    verticalCenter: parent.verticalCenter
                }
                onPressed: element.dataModel.autoReset = !element.dataModel.autoReset
            }
        }
    }
}
