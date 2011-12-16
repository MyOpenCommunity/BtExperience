import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fixedItem.height + buttonokcancel.height + (itemLoader.sourceComponent !== null ? itemLoader.height : 0)

    function alertOkClicked() {
        element.closeElement()
    }

    onChildDestroyed: {
        programItem.state = "";
    }

    function programSelected(programName) {
        programItem.description = programName
    }

    Connections {
        target: dataModel
        onProbeStatusChanged: {
            var desc = "";
            switch (dataModel.probeStatus) {
            case ThermalControlledProbe.Auto:
                itemLoader.sourceComponent = autoComponent
                desc = "auto"
                break
            case ThermalControlledProbe.Antifreeze:
                itemLoader.sourceComponent = undefined
                desc = "antigelo"
                break
            case ThermalControlledProbe.Manual:
                itemLoader.sourceComponent = manualComponent
                desc = "manuale"
                break
            case ThermalControlledProbe.Off:
                itemLoader.sourceComponent = undefined
                desc = "off"
                break
            }
            programSelected(desc)
        }
    }

    Image {
        id: fixedItem
        anchors.top: parent.top
        width: parent.width
        height: 100
        source: "images/common/dimmer_bg.png"

        Text {
            id: textTemperature
            x: 18
            y: 13
            text: dataModel.temperature  / 10 + qsTr("° C")
            font.pixelSize: 24
        }

        MenuItem {
            id: programItem
            name: qsTr("programma")
            x: 0
            y: 51

            onClicked: {
                element.loadElement("ThermalControlledProbePrograms.qml", programItem.name, dataModel)
                if (programItem.state == "")
                    programItem.state =  "selected"
            }
        }
    }

    Component {
        id: autoComponent
        ControlUpDown {
            title: qsTr("velocità fancoil")
            text: "alta"
        }
    }

    Component {
        id: manualComponent
        Column {
            ControlMinusPlus {
                title: qsTr("temperatura impostata")
                text: dataModel.setpoint / 10 + qsTr("° C")
                onPlusClicked: dataModel.setpoint += 1
                onMinusClicked: dataModel.setpoint -= 1
            }

            ControlUpDown {
                title: qsTr("velocità fancoil")
                text: "alta"
            }
        }
    }


    Loader {
        id: itemLoader
        anchors.top: fixedItem.bottom
    }

    ButtonOkCancel {
        id: buttonokcancel
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onCancelClicked: {
            page.showAlert(element, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            element.closeElement()
        }
    }


}
