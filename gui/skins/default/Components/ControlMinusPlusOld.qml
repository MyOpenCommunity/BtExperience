import QtQuick 1.1
import Components.Text 1.0


Image {
    id: control
    source: "../images/common/bg_UnaRegolazione.png"
    width: 212
    height: 100
    property alias title: title.text
    property alias text: label.text
    signal minusClicked
    signal plusClicked

    UbuntuLightText {
        id: title
        color: "#000000"
        text: qsTr("title")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }

    UbuntuLightText {
        id: label
        x: 32
        y: 65
        color: "#ffffff"
        text: qsTr("label")
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 15
    }

    Image {
        id: minus
        width: 43
        height: 45
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: plus.left
        source: "../images/common/btn_comando.png"

        Image {
            id: image7
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/common/meno.png"
        }

        BeepingMouseArea {
            id: minusMouseArea
            anchors.fill: parent
            onClicked: control.minusClicked()
        }
    }

    Image {
        id: plus
        width: 43
        height: 45
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        source: "../images/common/btn_comando.png"

        Image {
            id: image8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/common/piu.png"
        }

        BeepingMouseArea {
            id: plusMouseArea
            anchors.fill: parent
            onClicked: control.plusClicked()
        }
    }
}

