import QtQuick 1.1

Image {
    id: control
    source: "../images/common/bg_UnaRegolazione.png"
    width: 212
    height: 100
    property string title
    property string text
    signal minusClicked
    signal plusClicked

    Text {
        id: text1
        color: "#000000"
        text: "title"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }

    Text {
        id: label
        x: 32
        y: 65
        color: "#ffffff"
        text: "label"
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

        MouseArea {
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

        MouseArea {
            id: plusMouseArea
            anchors.fill: parent
            onClicked: control.plusClicked()
        }
    }
}

