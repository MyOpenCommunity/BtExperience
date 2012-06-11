import QtQuick 1.1
import Components.Text 1.0


Image {
    id: controlBalance
    source: "../images/common/bg_DueRegolazioni.png"
    width: 212
    height: 150
    property int percentage: 30
    property string description: qsTr("balance")

    UbuntuLightText {
        id: labelText
        text: description
        anchors.top: controlBalance.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pixelSize: 12
        color: "#444546"
    }

    Image {
        id: image1
        x: 5
        y: 60
        width: 202
        height: 7
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../images/common/BarraBilanciamento.png"
    }

    Image {
        id: image2
        x: image1.width * controlBalance.percentage / 100
        width: 30
        height: 47
        anchors.verticalCenter: image1.verticalCenter
        source: "../images/common/CursoreBilanciamento.png"
    }

    ButtonLeftRight {
        anchors.bottom: controlBalance.bottom
        anchors.horizontalCenter: controlBalance.horizontalCenter
    }
}
