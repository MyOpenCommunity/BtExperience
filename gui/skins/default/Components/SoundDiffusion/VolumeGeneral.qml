import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Image {
    id: buttonSlider
    property alias description: label.text
    property string imagePath: "../../"

    source: imagePath + "images/common/bg_panel_212x100.svg"

    signal plusClicked
    signal minusClicked

    UbuntuMediumText {
        id: label
        font.pixelSize: 16
        color: "#444546"

        text: qsTr("volume")
        anchors {
            top: parent.top
            topMargin: Math.round(buttonSlider.height * 10 / 100)
            horizontalCenter: parent.horizontalCenter
        }
    }

    ButtonMinusPlus {
        id: buttons
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(buttonSlider.height * 10 / 100)
        onPlusClicked: buttonSlider.plusClicked()
        onMinusClicked: buttonSlider.minusClicked()
    }
}
