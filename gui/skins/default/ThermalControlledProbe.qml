import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fixedItem.height + itemLoader.height

    QtObject {
        id: privateProps
        property int pendingModality: -1
    }

    function alertOkClicked() {
        element.closeElement()
    }

    function okClicked() {
        if (privateProps.pendingModality !== dataModel.probeStatus)
            dataModel.probeStatus = privateProps.pendingModality
        closeElement();
    }

    function cancelClicked() {
        pageObject.showAlert(element, qsTr("unsaved changes. continue?"))
    }

    onChildDestroyed: {
        modalityItem.state = "";
    }

    onChildLoaded: {
        if (child.modalitySelected)
            child.modalitySelected.connect(modalitySelected)
    }

    Connections {
        target: dataModel
        onProbeStatusChanged: {
            modalitySelected(dataModel.probeStatus)
        }
    }

    function modalitySelected(modality) {
        privateProps.pendingModality = modality
        switch (modality) {
        case ThermalControlledProbe.Auto:
            itemLoader.setComponent(autoComponent)
            break
        case ThermalControlledProbe.Antifreeze:
            itemLoader.setComponent(antifreezeComponent)
            break
        case ThermalControlledProbe.Manual:
            itemLoader.setComponent(manualComponent)
            break
        case ThermalControlledProbe.Off:
            itemLoader.setComponent(offComponent)
            break
        case ThermalControlledProbe.Unknown:
            return
        }
        modalityItem.description = pageObject.names.get('PROBE_STATUS', modality)
    }

    Component.onCompleted: modalitySelected(dataModel.probeStatus)

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
            text: dataModel.temperature  / 10 + qsTr("°C")
            font.pixelSize: 24
        }

        MenuItem {
            id: modalityItem
            hasChild: true
            active: element.animationRunning === false
            name: qsTr("modes")
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
                title: qsTr("fan coil speed")
                text: qsTr("high")
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
            id: rootManualComponent
            property int setpoint

            ControlMinusPlus {
                title: qsTr("temperature set")
                text: setpoint / 10 + qsTr("°C")
                onPlusClicked: setpoint += 1
                onMinusClicked: setpoint -= 1
            }

            ControlUpDown {
                title: qsTr("fan coil speed")
                text: qsTr("high")
            }

            ButtonOkCancel {
                onCancelClicked: {
                    setpoint = dataModel.setpoint
                    element.cancelClicked()

                }
                onOkClicked: {
                    dataModel.setpoint = setpoint
                    element.okClicked()
                }
            }

            Component.onCompleted: {
                rootManualComponent.setpoint = dataModel.setpoint // we want an assignment, not a binding
            }
            Connections {
                target: dataModel
                onSetpointChanged: {
                    rootManualComponent.setpoint = setpoint
                }
            }
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.top: fixedItem.bottom
    }
}

