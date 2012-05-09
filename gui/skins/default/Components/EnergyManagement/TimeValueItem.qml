import QtQuick 1.1


Rectangle {
    id: bg

    property string label: "€"

    color: "light grey"
    width: 100
    height: parent.height
    Text {
        id: txtLabel
        text: label
        font.pixelSize: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    states: [
        State {
            name: "selected"

            PropertyChanges {
                target: bg
                color: "black"
            }

            PropertyChanges {
                target: txtLabel
                color: "white"
            }
        },
        State {
            name: "legend"

            PropertyChanges {
                target: bg
                color: "transparent"
            }

            PropertyChanges {
                target: txtLabel
                color: "white"
            }
        }
    ]
}
