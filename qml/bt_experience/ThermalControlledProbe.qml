import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fixedItem.height + (itemLoader.sourceComponent !== null ? itemLoader.height : 0)

    function alertOkClicked() {
        element.closeElement()
    }

    function okClicked() {
        closeElement();
    }

    function cancelClicked() {
        page.showAlert(element, "Modifiche non salvate. Continuare?")
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
                itemLoader.sourceComponent = antifreezeComponent
                desc = "antigelo"
                break
            case ThermalControlledProbe.Manual:
                itemLoader.sourceComponent = manualComponent
                desc = "manuale"
                break
            case ThermalControlledProbe.Off:
                itemLoader.sourceComponent = offComponent
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
        id: offComponent
        ButtonOkCancel {
            onCancelClicked: element.cancelClicked();
            onOkClicked: element.okClicked();
        }
    }

    Component {
        id: antifreezeComponent
        ButtonOkCancel {
            onCancelClicked: element.cancelClicked();
            onOkClicked: element.okClicked();
        }
    }

    Component {
        id: autoComponent
        Column {
            ControlUpDown {
                title: qsTr("velocità fancoil")
                text: "alta"
            }

            ButtonOkCancel {
                onCancelClicked: element.cancelClicked();
                onOkClicked: element.okClicked();
            }
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

            ButtonOkCancel {
                onCancelClicked: element.cancelClicked();
                onOkClicked: element.okClicked();
            }
        }
    }

    Loader {
        id: itemLoader
        anchors.top: fixedItem.bottom
    }

}
