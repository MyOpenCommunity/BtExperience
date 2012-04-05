import QtQuick 1.1

Image {
    id: control
    source: "../images/common/bg_DueRegolazioni.png"
    width: 212
    height: 100
    property string description: qsTr("volume")
    property string choice: ""

    signal plusClicked
    signal minusClicked

    Text {
        id: label
        text: control.description
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: control.top
        anchors.topMargin: 5
    }

    Text {
        id: choice
        text: control.choice
        font.pixelSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: label.bottom
        anchors.topMargin: 5
    }

    ButtonMinusPlus {
        id: buttons
        onPlusClicked: control.plusClicked()
        onMinusClicked: control.minusClicked()
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
