import QtQuick 1.1

// On/Off control
// status: -1 no button is down ever, 0 off button is down, 1 on button is down
Item {
    id: control

    property int status: -1

    signal clicked(bool newStatus)

    width: bg.width
    height: bg.height

    SvgImage {
        id: bg
        source: "../images/common/bg_comando.svg"
    }

    Row {
        anchors.centerIn: parent // in this way we need no margins
        ButtonThreeStatesIcon {
            defaultImage: "../images/common/btn_apriporta_ok_on.svg"
            pressedImage: "../images/common/btn_apriporta_ok_on_P.svg"
            selectedImage: "../images/common/btn_apriporta_ok_on.svg"
            defaultIcon: "../images/common/ico_apriporta.svg"
            pressedIcon: "../images/common/ico_apriporta_P.svg"
            selectedIcon: "../images/common/ico_apriporta.svg"
            shadowImage: "../images/common/ombra_btn_apriporta_ok_on.svg"
            onClicked: control.clicked(true)
            //status: 1
        }
    }

}
