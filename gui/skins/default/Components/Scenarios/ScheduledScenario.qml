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
            source: "../../images/common/bg_on-off.svg"

            Row {
                anchors.centerIn: parent // in this way we need no margins

                ButtonImageThreeStates {
                    defaultImageBg: "../../images/common/btn_99x35.svg"
                    pressedImageBg: "../../images/common/btn_99x35_P.svg"
                    selectedImageBg: "../../images/common/btn_99x35_S.svg"
                    shadowImage: "../../images/common/btn_shadow_99x35.svg"
                    defaultImage: "../../images/common/icon_disabled.svg"
                    pressedImage: "../../images/common/icon_disabled_P.svg"
                    selectedImage: "../../images/common/icon_disabled_P.svg"

                    onClicked: column.dataModel.disable()
                }

                ButtonImageThreeStates {
                    defaultImageBg: "../../images/common/btn_99x35.svg"
                    pressedImageBg: "../../images/common/btn_99x35_P.svg"
                    selectedImageBg: "../../images/common/btn_99x35_S.svg"
                    shadowImage: "../../images/common/btn_shadow_99x35.svg"
                    defaultImage: "../../images/common/icon_enabled.svg"
                    pressedImage: "../../images/common/icon_enabled_P.svg"
                    selectedImage: "../../images/common/icon_enabled_P.svg"
                    onClicked: column.dataModel.enable()
                }
            }
        }
    }
}
