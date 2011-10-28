import QtQuick 1.1
import QtQuick 1.0


MenuElement {
    id: element
    width: 212
    height: 340

    function alertOkClicked() {
        element.closeElement()
    }

    onChildDestroyed: {
        imageBg.current_element = -1
    }

    Image {
        id: imageBg
        x: 0
        y: 0
        width: 212
        height: 170
        source: "common/dimmer_bg.png"
        property int current_element: -1



        Text {
            id: text1
            x: 22
            y: 68
            width: 115
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
            x: 22
            y: 113
            width: 79
            height: 19
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
            font.pixelSize: 14
        }

        ButtonCommand {
            x: 159
            y: 68
            width: 43
            height: 45
            selected: imageBg.current_element == 1

            onClicked: {
                if (!selected) {
                    element.loadChild("DATA", "ThermalCentralUnitDate.qml")
                    imageBg.current_element = 1
                }
            }
        }

        ButtonCommand {
            x: 159
            y: 113
            width: 43
            height: 45
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
        x: 1
        y: 170
        width: 212
        height: 118
        source: "common/comando_bg.png"

        Image {
            id: image3
            x: 112
            y: 59
            width: 49
            height: 53
            source: "common/btn_comando.png"

            Image {
                id: image9
                x: 14
                y: 16
                source: "common/freccia_up.png"
            }
        }

        Image {
            id: image4
            x: 160
            y: 59
            width: 49
            height: 53
            source: "common/btn_comando.png"

            Image {
                id: image10
                x: 14
                y: 16
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
            font.pixelSize: 14
        }

        Text {
            id: text5
            x: 18
            y: 68
            width: 96
            height: 38
            color: "#ffffff"
            text: qsTr("P3 Settimanale")
            font.bold: false
            wrapMode: Text.WordWrap
            font.pixelSize: 14
        }
    }

    ButtonOkCancel {
        id: buttonokcancel1
        x: 2
        y: 288
        onCancelClicked: {
            page.showAlert(element, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            element.closeElement()
        }
    }
}
