import QtQuick 1.1

Image {
    id: control
    source: "../images/common/comando_bg.png"
    width: 212
    height: 118
    property string title
    property string text
    signal minusClicked
    signal plusClicked

    Text {
        id: text1
        x: 17
        y: 12
        width: 158
        height: 15
        color: "#000000"
        text: title
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }

    Text {
        id: label
        x: 17
        y: 78
        width: 24
        height: 15
        color: "#ffffff"
        text:  control.text
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 15
    }

    Image {
        id: minus
        x: 111
        y: 59
        width: 49
        height: 53
        source: "../images/common/btn_comando.png"

        Image {
            id: image4
            x: 14
            y: 15
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
        x: 160
        y: 59
        width: 49
        height: 53
        source: "../images/common/btn_comando.png"

        Image {
            id: image5
            x: 14
            y: 15
            source: "../images/common/piu.png"
        }

        MouseArea {
            id: plusMouseArea
            anchors.fill: parent
            onClicked: control.plusClicked()
        }
    }
}

