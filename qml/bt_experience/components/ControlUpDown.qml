import QtQuick 1.1


Image {
    id: control
    width: 212
    height: 112
    source: "../images/common/comando_bg.png"

    property string title
    property string text
    signal downClicked()
    signal upClicked()


    Image {
        id: up
        x: 111
        y: 56
        width: 49
        height: 51
        source: "../images/common/btn_comando.png"

        Image {
            id: image7
            x: 14
            y: 15
            source: "../images/common/freccia_up.png"
        }

        MouseArea {
            id: mouse_area1
            anchors.fill: parent
            onClicked: control.upClicked()
        }
    }

    Text {
        id: text3
        x: 19
        y: 14
        width: 154
        height: 15
        text: title
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }

    Text {
        id: label
        x: 19
        y: 72
        color: "#ffffff"
        text:  control.text
        font.pixelSize: 15
    }

    Image {
        id: down
        x: 160
        y: 56
        width: 49
        height: 51
        source: "../images/common/btn_comando.png"

        Image {
            id: image8
            x: 14
            y: 15
            source: "../images/common/freccia_dw.png"
        }

        MouseArea {
            id: mouse_area2
            anchors.fill: parent
            onClicked: control.downClicked()
        }
    }
}

