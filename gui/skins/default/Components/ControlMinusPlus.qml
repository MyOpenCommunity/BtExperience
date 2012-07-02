import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: control

    property string text: "7 seconds"
    property string title: "temperature"
    property bool changeable: true

    signal minusClicked
    signal plusClicked

    source: "../images/termo/selettore/bg_selettore.svg"

    UbuntuLightText {
        id: title
        color: "black"
        text: control.title
        font.pixelSize: 13
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: value

        anchors {
            verticalCenter: rightButton.verticalCenter
            left: parent.left
            leftMargin: 7
        }
        font.pixelSize: 13
        color: "white"
        text: control.text
    }

    ButtonImageThreeStates {
        visible: control.changeable
        defaultImageBg: "../images/termo/selettore/btn_frecce.svg"
        pressedImageBg: "../images/termo/selettore/btn_frecce_P.svg"
        shadowImage: "../images/termo/selettore/ombra_btn_frecce.svg"
        defaultImage: "../images/termo/selettore/ico_meno.svg"
        pressedImage: "../images/termo/selettore/ico_meno_P.svg"
        timerEnabled: true
        onClicked: minusClicked()
        status: 0
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: rightButton.left
            rightMargin: 3
        }
    }

    ButtonImageThreeStates {
        id: rightButton
        visible: control.changeable
        defaultImageBg: "../images/termo/selettore/btn_frecce.svg"
        pressedImageBg: "../images/termo/selettore/btn_frecce_P.svg"
        shadowImage: "../images/termo/selettore/ombra_btn_frecce.svg"
        defaultImage: "../images/termo/selettore/ico_piu.svg"
        pressedImage: "../images/termo/selettore/ico_piu_P.svg"
        timerEnabled: true
        onClicked: plusClicked()
        status: 0
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: parent.right
            rightMargin: 7
        }
    }
}
