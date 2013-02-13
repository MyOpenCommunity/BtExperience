import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: buttonSlider

    property int percentage: 70
    property alias description: label.text
    property bool sliderEnabled: true

    signal plusClicked
    signal minusClicked
    signal sliderClicked(int desiredPercentage)

    onPercentageChanged: slider.actualPercentage = percentage

    source: "../images/common/bg_panel_212x100.svg"

    UbuntuLightText {
        id: label

        anchors {
            top: parent.top
            topMargin: buttonSlider.height / 100 * 5
            left: parent.left
            leftMargin: buttonSlider.width / 100 * 3.30
        }

        text: qsTr("volume")
        font.pixelSize: 15
        color: "#444546"
    }

    UbuntuLightText {
        id: percentageLabel

        anchors {
            top: parent.top
            topMargin: buttonSlider.height / 100 * 5
            right: parent.right
            rightMargin: buttonSlider.width / 100 * 7.07
        }

        // It's tempting to use slider.actualPercentage to link them together,
        // but it makes more evident the fact that we are rounding the volume
        // It doesn't look nice.
        text: percentage + " %"
        font.pixelSize: 15
        color: "#444546"
    }

    SvgImage {
        id: imageSlider

        anchors {
            top: label.bottom
            topMargin: buttonSlider.height / 100 * 10
            horizontalCenter: parent.horizontalCenter
        }

        source: "../images/common/bg_regola_dimmer.svg"

        Rectangle {
            id: slider

            property int actualPercentage: 50

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: -buttonSlider.width / 100 * 0.94
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

            states: [
                State {
                    name: "blinking"
                    when: slider.actualPercentage !== buttonSlider.percentage
                    PropertyChanges { target: blinkingAnimation; running: true }
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

    SequentialAnimation {
        id: blinkingAnimation

        property int totalDuration: 1000
        loops: Animation.Infinite
        alwaysRunToEnd: true

        NumberAnimation {
            targets: [slider, percentageLabel]
            property: "opacity"
            from: 1
            to: 0.4
            duration: blinkingAnimation.totalDuration / 2
        }
        NumberAnimation {
            targets: [slider, percentageLabel]
            property: "opacity"
            from: 0.4
            to: 1
            duration: blinkingAnimation.totalDuration / 2
        }
    }

    BeepingMouseArea {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: imageSlider.bottom
        }
        enabled: sliderEnabled

        onPressed: slider.actualPercentage = privateProps.getPercentageFromCoordinate(mouse.x)
        onPositionChanged: slider.actualPercentage = privateProps.getPercentageFromCoordinate(mouse.x)
        onReleased: frameDestormerTimer.restart()
    }

    Row {
        anchors {
            top: imageSlider.bottom
            topMargin: buttonSlider.height / 100 * 5
            horizontalCenter: parent.horizontalCenter
        }

        ButtonImageThreeStates {
            defaultImageBg: "../images/common/btn_99x35.svg"
            pressedImageBg: "../images/common/btn_99x35_P.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultImage: "../images/common/ico_meno.svg"
            pressedImage: "../images/common/ico_meno_P.svg"
            onClicked: minusClicked()
            repetitionOnHold: true
        }

        ButtonImageThreeStates {
            defaultImageBg: "../images/common/btn_99x35.svg"
            pressedImageBg: "../images/common/btn_99x35_P.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultImage: "../images/common/ico_piu.svg"
            pressedImage: "../images/common/ico_piu_P.svg"
            onClicked: plusClicked()
            repetitionOnHold: true
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
}
