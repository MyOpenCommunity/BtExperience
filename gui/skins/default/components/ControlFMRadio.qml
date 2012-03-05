import QtQuick 1.1

Image {
    id: control
    width: 212
    height: 100
    property string radioName: "Radio Cassadritta"
    property string radioFrequency: "FM 108.7"

    source: "../images/common/bg_UnaRegolazione.png"

    Image {
        id: minus
        x: 111
        y: 43
        width: 49
        height: 53
        source: "../images/common/btn_comando.png"

        Image {
            id: image4
            anchors.centerIn: parent
            source: "../images/common/precedente.png"
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
        y: 43
        width: 49
        height: 53
        source: "../images/common/btn_comando.png"

        Image {
            id: image5
            anchors.centerIn: parent
            source: "../images/common/successivo.png"
        }

        MouseArea {
            id: plusMouseArea
            anchors.fill: parent
            onClicked: control.plusClicked()
        }
    }

    Text_12pt_bold {
        id: text1
        y: 10
        anchors.horizontalCenter: control.horizontalCenter
        text: control.radioName
    }

    Text {
        id: text2
        x: 15
        y: 62
        text: control.radioFrequency
        font.pointSize: 12
        color: "white"
    }


}
