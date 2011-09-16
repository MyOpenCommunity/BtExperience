import QtQuick 1.1
import QtQuick 1.0


MenuElement {
    id: element
    width: 192
    height: 300

    Image {
        id: imageBg
        x: 0
        y: 0
        source: "common/dimmer_bg.png"
        property int current_element: -1



        Text {
            id: text1
            x: 20
            y: 65
            width: 79
            height: 24
            color: "#ffffff"
            text: qsTr("18/01/2012")
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            font.pixelSize: 16
        }

        Text {
            id: text2
            x: 20
            y: 111
            color: "#ffffff"
            text: qsTr("13:00")
            font.bold: true
            verticalAlignment: Text.AlignTop
            font.pixelSize: 16
        }

        Text {
            id: text3
            x: 22
            y: 11
            width: 149
            height: 15
            text: qsTr("attivo fino al")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
        }

        ButtonCommand {
            x: 144
            y: 53
            selected: imageBg.current_element == 1

            onClicked: {
                if (!selected) {
                    element.loadChild("DATA", "ThermalCentralUnitDate.qml")
                    imageBg.current_element = 1
                }
            }
        }

        ButtonCommand {
            x: 144
            y: 98
            selected: imageBg.current_element == 2
            onClicked: {
                if (!selected) {
                    element.loadChild("ORA", "ThermalCentralUnitTime.qml")
                    imageBg.current_element = 2
                }
            }
        }
    }

    Image {
        id: image2
        x: 0
        y: 150
        source: "common/comando_bg.png"

        Image {
            id: image3
            x: 101
            y: 49
            source: "common/comando.png"

            Image {
                id: image9
                x: 11
                y: 12
                source: "common/freccia_up.png"
            }
        }

        Image {
            id: image4
            x: 144
            y: 49
            source: "common/comando.png"

            Image {
                id: image10
                x: 11
                y: 12
                source: "common/freccia_dw.png"
            }
        }

        Text {
            id: text4
            x: 24
            y: 16
            text: qsTr("programma successivo")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
        }

        Text {
            id: text5
            x: 18
            y: 55
            width: 73
            height: 28
            color: "#ffffff"
            text: qsTr("P3 Settimanale")
            font.bold: false
            wrapMode: Text.WordWrap
            font.pixelSize: 13
        }
    }

    ButtonOkCancel {
        id: buttonokcancel1
        x: 0
        y: 250
    }
}
