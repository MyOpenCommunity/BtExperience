import QtQuick 1.1

// On/Off control
// status: -1 no button is down ever, 0 off button is down, 1 on button is down
SvgImage {
    id: control

    property int status: -1
    property string onText: qsTr("ON")
    property string offText: qsTr("OFF")

    signal clicked(bool newStatus)

    source: "../images/common/bg_on-off.svg"

    Row {
        anchors.centerIn: parent // in this way we need no margins

        ButtonThreeStates {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            text: onText
            onClicked: control.clicked(true)
            status: status === -1 ? 0 : (status ? 1 : 0)
        }

        ButtonThreeStates {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            text: offText
            onClicked: control.clicked(false)
            status: status === -1 ? 0 : (status ? 0 : 1)
        }
    }

}
