import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: control

    property string text: "7 seconds"

    signal leftClicked
    signal rightClicked

    UbuntuLightText {
        id: timing

        anchors {
            verticalCenter: rightButton.verticalCenter
            left: parent.left
            leftMargin: 7
        }
        font.pixelSize: 15
        color: "white"
        text: control.text
    }

    ButtonImageThreeStates {
        defaultImageBg: "../images/common/btn_frecce.svg"
        pressedImageBg: "../images/common/btn_frecce_P.svg"
        shadowImage: "../images/common/ombra_btn_frecce.svg"
        defaultImage: "../images/common/ico_freccia_sx.svg"
        pressedImage: "../images/common/ico_freccia_sx_P.svg"
        onClicked: leftClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: rightButton.left
            rightMargin: 3
        }
    }

    ButtonImageThreeStates {
        id: rightButton
        defaultImageBg: "../images/common/btn_frecce.svg"
        pressedImageBg: "../images/common/btn_frecce_P.svg"
        shadowImage: "../images/common/ombra_btn_frecce.svg"
        defaultImage: "../images/common/ico_freccia_dx.svg"
        pressedImage: "../images/common/ico_freccia_dx_P.svg"
        onClicked: rightClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: parent.right
            rightMargin: 7
        }
    }
}
