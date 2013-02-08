import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: control

    property string text: "7 seconds"
    property string title: "temperature"
    property bool changeable: true
    property int slowClickInterval: 350
    property int fastClickInterval: 100

    signal minusClicked
    signal plusClicked

    source: "../images/common/panel_212x73.svg"

    UbuntuLightText {
        id: title
        color: "black"
        text: control.title
        font.pixelSize: 15
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
        font.pixelSize: 15
        color: "white"
        text: control.text
    }

    ButtonImageThreeStates {
        visible: control.changeable
        defaultImageBg: "../images/common/btn_frecce.svg"
        pressedImageBg: "../images/common/btn_frecce_P.svg"
        shadowImage: "../images/common/ombra_btn_frecce.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        repetitionOnHold: true
        largeInterval: slowClickInterval
        smallInterval: fastClickInterval
        onClicked: minusClicked()
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
        defaultImageBg: "../images/common/btn_frecce.svg"
        pressedImageBg: "../images/common/btn_frecce_P.svg"
        shadowImage: "../images/common/ombra_btn_frecce.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        repetitionOnHold: true
        largeInterval: slowClickInterval
        smallInterval: fastClickInterval
        onClicked: plusClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: parent.right
            rightMargin: 7
        }
    }
}
