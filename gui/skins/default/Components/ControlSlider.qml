import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: buttonSlider

    property int percentage: 70
    property alias description: label.text

    signal plusClicked
    signal minusClicked

    source: "../images/common/bg_panel_212x100.svg"

    UbuntuLightText {
        id: label

        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }

        text: qsTr("volume")
        font.pixelSize: 15
        color: "#444546"
    }

    UbuntuLightText {
        id: percentageLabel

        anchors {
            top: parent.top
            topMargin: 5
            right: parent.right
            rightMargin: 15
        }

        text: percentage + " %"
        font.pixelSize: 15
        color: "#444546"
    }

    SvgImage {
        id: image2

        anchors {
            top: label.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        source: "../images/common/bg_regola_dimmer.svg"

        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: -2
            }

            height: parent.height + 2
            width: parent.width * (buttonSlider.percentage < 10 ? 10 : buttonSlider.percentage) / 100 + 4
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

    Row {
        anchors {
            top: image2.bottom
            topMargin: 5
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
}
