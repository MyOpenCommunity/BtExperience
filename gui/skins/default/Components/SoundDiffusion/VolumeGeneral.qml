import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Image {
    id: buttonSlider
    width: 212
    height: 100
    property string description: qsTr("volume")
    property string imagePath: "../../"

    source: imagePath + "images/common/bg_UnaRegolazione.png"

    signal plusClicked
    signal minusClicked

    UbuntuLightText {
        id: label
        x: 85
        y: 15
        font {
            bold: true
            pixelSize: 16
        }
        color: "#444546"

        text: buttonSlider.description
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ButtonMinusPlus {
        id: buttons
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        onPlusClicked: buttonSlider.plusClicked()
        onMinusClicked: buttonSlider.minusClicked()
    }
}
