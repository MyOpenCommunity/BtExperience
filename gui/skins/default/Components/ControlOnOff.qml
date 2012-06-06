import QtQuick 1.1


SvgImage {
    id: control

    property bool active: false
    property string onText: qsTr("ON")
    property string offText: qsTr("OFF")

    signal clicked(bool newStatus)

    source: "../images/common/panel_on-off.svg"

    Row {
        anchors.centerIn: parent // in this way we need no margins

        ButtonThreeStates {
            defaultImage: "../images/common/button_1-2.svg"
            pressedImage: "../images/common/button_1-2_p.svg"
            selectedImage: "../images/common/button_1-2_s.svg"
            shadowImage: "../images/common/shadow_button_1-2.svg"
            text: onText
            onClicked: control.clicked(true)
            status: active ? 1 : 0
        }

        ButtonThreeStates {
            defaultImage: "../images/common/button_1-2.svg"
            pressedImage: "../images/common/button_1-2_p.svg"
            selectedImage: "../images/common/button_1-2_s.svg"
            shadowImage: "../images/common/shadow_button_1-2.svg"
            text: offText
            onClicked: control.clicked(false)
            status: active ? 0 : 1
        }
    }

}
