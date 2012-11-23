import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: buttonSlider

    property int percentage: 70
    property string description: qsTr("volume")

    signal plusClicked
    signal minusClicked

    source: "../images/common/bg_dimmer.svg"

    UbuntuLightText {
        id: label
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 7
        font.pixelSize: 13
        color: "#444546"
        text: buttonSlider.description
    }

    UbuntuLightText {
        id: percentageLabel
        text: percentage + " %"
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 15
        font.pixelSize: 13
        color: "#444546"
    }

    SvgImage {
        id: image2
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
            status: 0
        }

        ButtonImageThreeStates {
            defaultImageBg: "../images/common/btn_99x35.svg"
            pressedImageBg: "../images/common/btn_99x35_P.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultImage: "../images/common/ico_piu.svg"
            pressedImage: "../images/common/ico_piu_P.svg"
            onClicked: plusClicked()
            repetitionOnHold: true
            status: 0
        }
    }
}
