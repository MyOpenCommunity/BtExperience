import QtQuick 1.1
import Components.Text 1.0


Image {
    id: control
    width: 212
    height: 100
    source: "../images/common/bg_UnaRegolazione.png"

    property alias title: title.text
    property alias text: label.text
    signal downClicked()
    signal upClicked()


    Image {
        id: up
        width: 43
        height: 45
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: down.left
        source: "../images/common/btn_comando.png"

        Image {
            id: image7
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/common/freccia_up.png"
        }

        MouseArea {
            id: mouse_area1
            anchors.fill: parent
            onClicked: control.upClicked()
        }
    }

    UbuntuLightText {
        id: title
        text: qsTr("title")
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }

    UbuntuLightText {
        id: label
        x: 33
        y: 64
        color: "#ffffff"
        text: qsTr("label")
        anchors.left: parent.left
        anchors.leftMargin: 33
        font.pixelSize: 15
        wrapMode: Text.WordWrap
    }

    Image {
        id: down
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
            source: "../images/common/freccia_dw.png"
        }

        MouseArea {
            id: mouse_area2
            anchors.fill: parent
            onClicked: control.downClicked()
        }
    }
}

