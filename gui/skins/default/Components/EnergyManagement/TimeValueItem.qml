import QtQuick 1.1
import Components.Text 1.0


Rectangle {
    id: bg

    property string label: "euro"

    signal clicked

    color: "light grey"
    width: 100
    height: parent.height

    radius: 4
    anchors.margins: 1

    UbuntuLightText {
        id: txtLabel
        text: label
        font.pixelSize: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: bg.clicked()
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
