import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: buttonSlider

    property int percentage: 70
    property string description: qsTr("volume")
    property alias muteEnabled: buttonMute.enabled

    signal plusClicked
    signal minusClicked
    signal muteClicked

    source: "../images/common/bg_regola_volume.svg"

    Rectangle {
        id: darkRect
        z: 1
        anchors.fill: parent
        color: "black"
        opacity: 0.2
        visible: false
        // please note that mouse clicks are not blocked here
    }

    UbuntuMediumText {
        id: label
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 7
        font.pixelSize: 14
        color: "gray"
        text: buttonSlider.description
    }

    UbuntuMediumText {
        id: percentageLabel
        text: percentage + " %"
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 15
        font.pixelSize: 14
        color: "white"
    }

    SvgImage {
        id: imageSlider
        anchors.top: label.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../images/common/bar_dimmer_bg.svg"

        Rectangle {
            height: parent.height + 2
            width: parent.width * (buttonSlider.percentage < 10 ? 10 : buttonSlider.percentage) / 100 + 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: -2
            radius: 100
            smooth: true
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#a9abad"
                }
                GradientStop {
                    position: 1.0
                    color: "#5c5c5c"
                }
            }
        }
    }

    ButtonImageThreeStates {
        id: buttonMute
        z: 2 // must always be enabled
        defaultImageBg: "../images/common/btn_mute.svg"
        pressedImageBg: "../images/common/btn_mute_P.svg"
        shadowImage: "../images/common/ombra_btn_mute.svg"
        defaultImage: "../images/common/ico_mute.svg"
        pressedImage: "../images/common/ico_mute.svg"
        onClicked: muteClicked()
        status: 0
        anchors {
            top: imageSlider.bottom
            topMargin: 5
            left: imageSlider.left
        }
    }

    ButtonImageThreeStates {
        id: buttonMinus
        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        onClicked: minusClicked()
        status: 0
        anchors {
            top: imageSlider.bottom
            topMargin: 5
            right: buttonPlus.left
            rightMargin: 4
        }
    }

    ButtonImageThreeStates {
        id: buttonPlus
        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        onClicked: plusClicked()
        status: 0
        anchors {
            top: imageSlider.bottom
            topMargin: 5
            right: imageSlider.right
        }
    }

    states: [
        State {
            name: "mute"
            PropertyChanges { target: darkRect; visible: true }
            PropertyChanges { target: buttonMinus; enabled: false }
            PropertyChanges { target: buttonPlus; enabled: false }
            PropertyChanges {
                target: buttonMute
                defaultImageBg: "../images/common/btn_mute_on.svg"
                pressedImageBg: "../images/common/btn_mute_P.svg"
                shadowImage: "../images/common/ombra_btn_mute.svg"
                defaultImage: "../images/common/ico_mute_on.svg"
                pressedImage: "../images/common/ico_mute_on.svg"
                status: 0
            }
        }
    ]
}
