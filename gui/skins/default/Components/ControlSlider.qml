import QtQuick 1.1

Image {
    id: buttonSlider
    source: "../images/common/option_panel_background.svg"
    property int percentage: 70
    property string description: qsTr("volume")

    signal plusClicked
    signal minusClicked

    Text {
        id: label
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 15
        font.pointSize: 12
        font.bold: true
        color: "#444546"
        text: buttonSlider.description
    }

    Text {
        id: percentageLabel
        text: percentage + " %"
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 15
        font.pointSize: 12
        color: "#444546"
    }

    SvgImage {
        id: image2
        anchors.top: label.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../images/common/button_space_background.svg"

        Rectangle {
            height: parent.height + 2
            width: parent.width * (buttonSlider.percentage < 10 ? 10 : buttonSlider.percentage) / 100 + 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: -2
            radius: 100
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#b1b3b4"
                }
                GradientStop {
                    position: 1.0
                    color: "#7a797b"
                }
            }
        }
    }

    TwoButtonsSettingsLarge {
        anchors.top: image2.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        onLeftClicked: minusClicked()
        onRightClicked: plusClicked()
    }
}
