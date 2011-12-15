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
        expireDateTime.current_element = -1
    }

    Image {
        id: expireDateTime
        anchors.top: parent.top
        width: 212
        height: 170
        source: "images/common/dimmer_bg.png"
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
            selected: expireDateTime.current_element == 1

            onClicked: {
                if (!selected) {
                    element.loadElement("ThermalCentralUnitDate.qml", "data")
                    expireDateTime.current_element = 1
                }
            }
        }

        ButtonCommand {
            x: 159
            y: 113
            width: 43
            height: 45
            selected: expireDateTime.current_element == 2
            onClicked: {
                if (!selected) {
                    element.loadElement("ThermalCentralUnitTime.qml", "ora")
                    expireDateTime.current_element = 2
                }
            }
        }
    }

    ControlUpDown {
        id: programSelector
        anchors.top: expireDateTime.bottom

        function scrollProgram(offset) {
            var next = element.dataModel.programIndex + offset
            next = (next + element.dataModel.programCount) % element.dataModel.programCount
            element.dataModel.programIndex = next
        }

        onUpClicked: programSelector.scrollProgram(-1)
        onDownClicked: programSelector.scrollProgram(1)
        title: qsTr("programma successivo")
        text: element.dataModel.programDescription
    }

    ButtonOkCancel {
        id: buttonokcancel1
        anchors.top: programSelector.bottom
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
