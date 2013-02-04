import QtQuick 1.1

// On/Off control
// status: -1 no button is down ever, 0 off button is down, 1 on button is down
Item {
    id: control

    property int status: 0
    property alias leftIcon: left.defaultIcon
    property alias leftPressedIcon: left.pressedIcon
    property alias rightIcon: right.defaultIcon
    property alias rightPressedIcon: right.pressedIcon

    signal pressed(int newStatus)

    width: bg.width
    height: bg.height

    SvgImage {
        id: bg
        source: "../images/common/bg_on-off.svg"
    }

    Row {
        anchors.centerIn: parent // in this way we need no margins

        ButtonThreeStatesAutomation {
            id: left
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            selectedIcon: ""
            onPressed: {
                control.status = (status === 0 ? 1 : 0)
                control.pressed(control.status)
            }
            status: control.status == 1 ? 1 : 0

        }

        ButtonThreeStatesAutomation {
            id: right
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            selectedIcon: ""
            onPressed: {
                control.status = (status === 0 ? 2 : 0)
                control.pressed(control.status)
            }
            status: control.status == 2 ? 1 : 0
        }
    }

}


