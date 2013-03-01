import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Column {
    id: control

    property alias text: leftText.text
    property alias repetitionWithSlowFastClicks: buttonPlus.repetitionWithSlowFastClicks

    signal plusClicked
    signal plusClickedSlow
    signal plusClickedFast
    signal minusClicked
    signal minusClickedSlow
    signal minusClickedFast

    ButtonImageThreeStates {
        id: buttonPlus

        z: 1
        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        repetitionOnHold: true
        onClicked: control.plusClicked()
        onClickedFast: control.plusClickedFast()
        onClickedSlow: control.plusClickedSlow()
    }

    SvgImage {
        id: bg
        source: "../images/common/bg_datetime.svg"
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

        z: 1
        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        repetitionOnHold: true
        repetitionWithSlowFastClicks: buttonPlus.repetitionWithSlowFastClicks
        onClicked: control.minusClicked()
        onClickedFast: control.minusClickedFast()
        onClickedSlow: control.minusClickedSlow()
    }
}
