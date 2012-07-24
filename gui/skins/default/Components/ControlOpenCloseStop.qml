import QtQuick 1.1

// On/Off control
// status: -1 no button is down ever, 0 off button is down, 1 on button is down
Item {
    id: control

    property int status: -1

    signal clicked(int newStatus)

    width: bg.width
    height: bg.height

    SvgImage {
        id: bg
        source: "../images/common/bg_on-off.svg"
    }

    Row {
        anchors.centerIn: parent // in this way we need no margins

        ButtonThreeStatesAutomation {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultIcon: "../images/common/ico_apri.svg"
            pressedIcon: "../images/common/ico_apri_P.svg"
            selectedIcon: ""
            onClicked: {control.clicked(status == 0 ? 1 : 0); console.log("ControlOpenCloseStop.qml A STATUS "+status+" CONTROL "+control.status)}
            status: control.status === -1 ? 0 : (control.status == 1 ? 1 : 0)

        }

        ButtonThreeStatesAutomation {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultIcon: "../images/common/ico_chiudi.svg"
            pressedIcon: "../images/common/ico_chiudi_P.svg"
            selectedIcon: ""
            onClicked: {control.clicked(status == 0 ? 2 : 0); console.log("ControlOpenCloseStop.qml B STATUS "+status+" CONTROL "+control.status)}
            status: control.status === -1 ? 0 : (control.status == 2 ? 1 : 0)
        }
    }

}

