import QtQuick 1.1


MenuElement {
    id: element
    width: 212
    height: 338

    signal programSelected(string programName)

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
            text: Qt.formatDate(element.dataModel.date, "dd/MM/yy")
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
            text: Qt.formatTime(element.dataModel.time, "hh:mm")
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
            font.pixelSize: 13
        }

        ButtonCommand {
            x: 159
            y: 68
            width: 43
            height: 45
            selected: imageBg.current_element == 1

            onClicked: {
                if (!selected) {
                    element.loadElement("ThermalCentralUnitDate.qml", "data")
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
                    element.loadElement("ThermalCentralUnitTime.qml", "ora")
                    imageBg.current_element = 2
                }
            }
        }
    }

    Image {
        id: programSelector
        x: 1
        y: 170
        width: 212
        height: 118
        source: "common/comando_bg.png"

        function scrollProgram(offset) {
            var next = element.dataModel.programIndex + offset

            next = (next + element.dataModel.programCount) % element.dataModel.programCount

            element.dataModel.programIndex = next
        }

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

            MouseArea {
                id: mouse_areaup
                anchors.fill: parent
                onClicked: programSelector.scrollProgram(-1)
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

            MouseArea {
                id: mouse_areadown
                anchors.fill: parent
                onClicked: programSelector.scrollProgram(1)
            }
        }

        Text {
            id: text4
            x: 24
            y: 16
            text: qsTr("programma successivo")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
        }

        Text {
            id: text5
            x: 18
            y: 68
            width: 96
            height: 38
            color: "#ffffff"
            text: element.dataModel.programDescription
            font.bold: false
            wrapMode: Text.WordWrap
            font.pixelSize: 14
        }
    }

    ButtonOkCancel {
        id: buttonokcancel1
        x: 0
        y: 288
        onCancelClicked: {
            page.showAlert(element, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            element.closeElement()
            element.programSelected(dataModel.programDescription)
            dataModel.apply()
        }
    }
}
