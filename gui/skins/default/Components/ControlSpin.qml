import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Column {
    id: control
    property alias text: leftText.text
    signal plusClicked
    signal minusClicked

    ButtonImageThreeStates {
        id: buttonPlus

        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        timerEnabled: true
        onClicked: control.plusClicked()
    }

    SvgImage {
        id: bg
        source: "../images/common/date_panel_inner_background.svg"
        height: 32
        anchors {
            left: buttonPlus.left
            right: buttonPlus.right
        }

        UbuntuLightText {
            id: leftText

            color: "#5b5b5b"
            font.pixelSize: 22
            anchors.centerIn: parent
        }
    }


    ButtonImageThreeStates {
        id: buttonMinus

        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        timerEnabled: true
        onClicked: control.minusClicked()
    }
}
