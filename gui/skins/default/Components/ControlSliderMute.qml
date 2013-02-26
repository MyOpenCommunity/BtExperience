import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: buttonSlider

    property int percentage: 70
    property string description: label.text
    property alias muteEnabled: buttonMute.enabled

    signal plusClicked
    signal minusClicked
    signal muteClicked
    signal sliderClicked(int desiredPercentage)

    onPercentageChanged: {
        slider.opacity = 1
        slider.actualPercentage = percentage
    }

    source: "../images/common/bg_panel_212x100.svg"

    Rectangle {
        id: darkRect

        z: 1
        anchors.fill: parent
        color: "black"
        opacity: 0.2
        visible: false
        // please note that mouse clicks are not blocked here
    }

    UbuntuLightText {
        id: label

        anchors {
            top: parent.top
            topMargin: Math.round(buttonSlider.height / 100 * 5)
            left: parent.left
            leftMargin: Math.round(buttonSlider.width / 100 * 3.30)
        }

        text: qsTr("volume")
        font.pixelSize: 14
        color: "gray"
    }

    UbuntuLightText {
        id: percentageLabel

        anchors {
            top: parent.top
            topMargin: Math.round(buttonSlider.height / 100 * 5)
            right: parent.right
            rightMargin: Math.round(buttonSlider.width / 100 * 7.07)
        }

        text: percentage + " %"
        font.pixelSize: 14
        color: "white"
    }

    SvgImage {
        id: imageSlider

        anchors {
            top: label.bottom
            topMargin: Math.round(buttonSlider.height / 100 * 10)
            horizontalCenter: parent.horizontalCenter
        }

        source: "../images/common/bg_regola_dimmer.svg"

        Rectangle {
            id: slider

            property int actualPercentage: 50

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: -Math.round(buttonSlider.width / 100 * 0.94)
            }

            height: parent.height + 2
            width: parent.width * (actualPercentage < 10 ? 10 : actualPercentage) / 100 + 4
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

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Timer {
                id: blinkingTimer

                interval: 500 // arbitrary value
                repeat: true
                running: false
                onTriggered: slider.opacity === 0 ? slider.opacity = 1 : slider.opacity = 0
            }

            states: [
                State {
                    name: "blinking"
                    when: slider.actualPercentage !== buttonSlider.percentage
                    PropertyChanges { target: blinkingTimer; running: true }
                }
            ]
        }

        Timer {
            id: frameDestormerTimer

            interval: 1000 // arbitrary value
            repeat: false
            onTriggered: sliderClicked(slider.actualPercentage)
        }
    }

    BeepingMouseArea {
        id: sliderArea
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: imageSlider.bottom
        }

        onPositionChanged: slider.actualPercentage = privateProps.getPercentageFromCoordinate(mouse.x)
        onReleased: frameDestormerTimer.restart()
    }

    ButtonImageThreeStates {
        id: buttonMute
        z: 2 // must always be enabled
        defaultImageBg: "../images/common/btn_45x35.svg"
        pressedImageBg: "../images/common/btn_45x35_P.svg"
        shadowImage: "../images/common/btn_shadow_45x35.svg"
        defaultImage: "../images/common/ico_mute.svg"
        pressedImage: "../images/common/ico_mute.svg"
        onPressed: muteClicked()
        anchors {
            top: imageSlider.bottom
            topMargin: Math.round(buttonSlider.height / 100 * 5)
            left: imageSlider.left
        }
    }

    ButtonImageThreeStates {
        id: buttonMinus
        defaultImageBg: "../images/common/btn_66x35.svg"
        pressedImageBg: "../images/common/btn_66x35_P.svg"
        shadowImage: "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        onClicked: minusClicked()
        repetitionOnHold: true
        anchors {
            top: imageSlider.bottom
            topMargin: Math.round(buttonSlider.height / 100 * 5)
            right: buttonPlus.left
            rightMargin: 4
        }
    }

    ButtonImageThreeStates {
        id: buttonPlus
        defaultImageBg: "../images/common/btn_66x35.svg"
        pressedImageBg: "../images/common/btn_66x35_P.svg"
        shadowImage: "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        onClicked: plusClicked()
        repetitionOnHold: true
        anchors {
            top: imageSlider.bottom
            topMargin: Math.round(buttonSlider.height / 100 * 5)
            right: imageSlider.right
        }
    }

    QtObject {
        id: privateProps

        property int _tolerance: 5

        function getPercentageFromCoordinate(coordX) {
            var logicalX = (coordX - _tolerance) / (imageSlider.width - _tolerance * 2)
            if (logicalX < 0) logicalX = 0
            if (logicalX > 1) logicalX = 1
            return Math.round(logicalX * 100)
        }
    }

    states: [
        State {
            name: "mute"
            PropertyChanges { target: darkRect; visible: true }
            PropertyChanges { target: buttonMinus; enabled: false }
            PropertyChanges { target: buttonPlus; enabled: false }
            PropertyChanges { target: sliderArea; enabled: false }
            PropertyChanges {
                target: buttonMute
                defaultImageBg: "../images/common/btn_mute_on.svg"
                pressedImageBg: "../images/common/btn_45x35_P.svg"
                shadowImage: "../images/common/btn_shadow_45x35.svg"
                defaultImage: "../images/common/ico_mute_on.svg"
                pressedImage: "../images/common/ico_mute_on.svg"
                status: 0
            }
        }
    ]
}
