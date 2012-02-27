// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Image {
    id: controlBalance
    source: "../images/common/bg_DueRegolazioni.png"
    width: 212
    height: 150
    property int percentage: 30
    property string description: "bilanciamento"

    Text {
        id: labelText
        text: description
        anchors.top: controlBalance.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 12
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
