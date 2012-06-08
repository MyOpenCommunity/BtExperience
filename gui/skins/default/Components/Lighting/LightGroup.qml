import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    SvgImage {
        id: image
        source: "../../images/common/panel_on-off.svg"

        Row {
            anchors.centerIn: parent // in this way we need no margins

            ButtonThreeStates {
                defaultImage: "../images/common/button_1-2.svg"
                pressedImage: "../images/common/button_1-2_p.svg"
                selectedImage: "../images/common/button_1-2_s.svg"
                shadowImage: "../images/common/shadow_button_1-2.svg"
                text: qsTr("ON")
                onClicked: dataModel.setActive(true)
                status: 0
            }

            ButtonThreeStates {
                defaultImage: "../images/common/button_1-2.svg"
                pressedImage: "../images/common/button_1-2_p.svg"
                selectedImage: "../images/common/button_1-2_s.svg"
                shadowImage: "../images/common/shadow_button_1-2.svg"
                text: qsTr("OFF")
                onClicked: dataModel.setActive(false)
                status: 0
            }
        }
    }
}
