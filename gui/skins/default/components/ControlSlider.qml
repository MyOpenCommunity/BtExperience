import QtQuick 1.1

Image {
    id: buttonSlider
    source: "../images/common/bg_DueRegolazioni.png"
    width: 212
    height: 150
    property int percentage: 85
    property string description: qsTr("Volume")

    Text {
        id: label
        x: 85
        y: 15
        text: buttonSlider.description
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 13
        font.bold: true
        color: "#444546"
    }

    Image {
        id: image2
        x: 5
        y: 43
        width: 202
        height: 49
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../images/common/bg_volume.png"

        Image {
            id: barPercentage
            source: "../images/common/dimmer_reg.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 1
            width: parent.width * buttonSlider.percentage / 100 - 1
            height: parent.height - 2
        }
    }

    ButtonMinusPlus {
        id: buttons
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
