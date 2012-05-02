import QtQuick 1.1
import Components 1.0

SvgImage {
    id: controlBalance
    source: "../images/common/option_panel_background.svg"
    // valid range: -10/+10
    property int balance: 10
    property string description: "balance"

    Text {
        id: labelText
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 15
        font.pointSize: 12
        font.bold: true
        color: "#444546"
        text: controlBalance.description
    }

    SvgImage {
        id: image1
        anchors.top: labelText.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../images/common/button_space_background.svg"

        Rectangle {
            height: parent.height + 2
            width: 28
            // the following should be -14 (to properly position the slider on
            // one edge at +/-10) but in that case we see a bit of background
            property int step: (parent.width / 2 - 10) / 10
            x: parent.width / 2 + (controlBalance.balance * step) - (width / 2)
            anchors.verticalCenter: parent.verticalCenter
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
        anchors.top: image1.bottom
        anchors.topMargin: 10
    }
}
