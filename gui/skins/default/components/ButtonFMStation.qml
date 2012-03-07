import QtQuick 1.1

Image {
    id: button
    source: "../images/sound_diffusion/btn_memorizza_radio.png"
    width: 40
    height: 50
    property int stationNumber: 1

    Image {
        id: savedStation
        anchors.top: parent.top
        anchors.horizontalCenter:  parent.horizontalCenter
        source: "../images/common/off.png"
        visible: false
        width: 34
        height: 34
    }

    Text {
        text: button.stationNumber
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }

    states: [
        State {
            name: ""
            PropertyChanges {
                target: savedStation
                visible: false
            }
        },
        State {
            name: "playing"
            PropertyChanges {
                target: savedStation
                visible: true
                source: "../images/common/on.png"
            }
        },
        State {
            name: "saved"
            PropertyChanges {
                target: savedStation
                visible: true
                source: "../images/common/off.png"
            }
        }
    ]
}
