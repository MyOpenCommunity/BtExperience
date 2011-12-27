import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fixedItem.height + itemLoader.height

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
        modalityItem.state = "";
    }

    Component.onCompleted: showModality()

    function showModality() {
        var desc = "";
        switch (dataModel.probeStatus) {
        case ThermalControlledProbe.Auto:
            itemLoader.setComponent(autoComponent)
            desc = "auto"
            break
        case ThermalControlledProbe.Antifreeze:
            itemLoader.setComponent(antifreezeComponent)
            desc = "antigelo"
            break
        case ThermalControlledProbe.Manual:
            itemLoader.setComponent(manualComponent)
            desc = "manuale"
            break
        case ThermalControlledProbe.Off:
            itemLoader.setComponent(offComponent)
            desc = "off"
            break
        }
        modalityItem.description = desc
    }

    Connections {
        target: dataModel
        onProbeStatusChanged: showModality()
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
            id: modalityItem
            name: qsTr("modalità")
            x: 0
            y: 51

            onClicked: {
                element.loadElement("ThermalControlledProbeModalities.qml", modalityItem.name, dataModel)
                if (modalityItem.state == "")
                    modalityItem.state =  "selected"
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

    AnimatedLoader {
        id: itemLoader
        anchors.top: fixedItem.bottom
    }
}

