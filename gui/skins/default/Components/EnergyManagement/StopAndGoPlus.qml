import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: element

    Column {
        SvgImage {
            source: "../../images/common/bg_panel_212x100.svg"

            ControlSwitch {
                upperText: qsTr("Automatic")
                text: qsTr("Reclosing")
                pixelSize: 14
                onPressed: element.dataModel.autoReset = !element.dataModel.autoReset
                status: !element.dataModel.autoReset
                enabled: element.dataModel.status === StopAndGo.Closed
            }

            ButtonThreeStates {
                id: openButton

                defaultImage: "../../images/common/btn_99x35.svg"
                pressedImage: "../../images/common/btn_99x35_P.svg"
                selectedImage: "../../images/common/btn_99x35_S.svg"
                shadowImage: "../../images/common/btn_shadow_99x35.svg"
                text: qsTr("open")
                font.pixelSize: 15
                onPressed: element.dataModel.open()
                anchors {
                    left: parent.left
                    leftMargin: 7
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 7
                }
            }

            ButtonThreeStates {
                id: closeButton

                defaultImage: "../../images/common/btn_99x35.svg"
                pressedImage: "../../images/common/btn_99x35_P.svg"
                selectedImage: "../../images/common/btn_99x35_S.svg"
                shadowImage: "../../images/common/btn_shadow_99x35.svg"
                text: qsTr("close")
                font.pixelSize: 15
                onPressed: element.dataModel.close()
                anchors {
                    right: parent.right
                    rightMargin: 7
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 7
                }
            }
        }

        ControlSwitch {
            visible: element.dataModel.status === StopAndGo.Opened
            upperText: qsTr("Check Faults")
            text: element.dataModel.diagnostic ? qsTr("Enabled") : qsTr("Disabled")
            pixelSize: 14
            onPressed: element.dataModel.diagnostic = !element.dataModel.diagnostic
            status: !element.dataModel.diagnostic
            enabled: element.dataModel.status !== StopAndGo.Closed
        }
    }
}
