import QtQuick 1.1

// On/Off control
// status: -1 no button is down ever, 0 off button is down, 1 on button is down
Item {
    id: control

    property int status: -1
    property string onText: qsTr("ON")
    property string offText: qsTr("OFF")

    property alias onEnabled: onButton.enabled
    property alias offEnabled: offButton.enabled
    signal clicked(bool newStatus)

    width: bg.width
    height: bg.height

    SvgImage {
        id: bg
        source: "../images/common/bg_on-off.svg"
    }

    Row {
        anchors.centerIn: parent // in this way we need no margins

        ButtonThreeStates {
            id: onButton
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            text: onText
            onClicked: control.clicked(true)
            status: control.status === -1 ? 0 : (control.status ? 1 : 0)
        }

        ButtonThreeStates {
            id: offButton
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            text: offText
            onClicked: control.clicked(false)
            status: control.status === -1 ? 0 : (control.status ? 0 : 1)
        }
    }

}
