import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    property int is99zones: (dataModel.centralType === ThermalControlledProbe.CentralUnit99Zones)

    height: fixedItem.height + modalityItem.height + itemLoader.height

    Component {
        id: thermalControlledProbeModalities
        ThermalControlledProbeModalities {}
    }

    QtObject {
        id: privateProps
        property int pendingModality: -1
    }

    function isFancoil() {
        return (column.dataModel.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
    }

    function alertOkClicked() {
        column.closeColumn()
    }

    function okClicked() {
        if (privateProps.pendingModality !== dataModel.probeStatus) {
            dataModel.probeStatus = privateProps.pendingModality
            privateProps.pendingModality = -1
        }
        closeColumn()
    }

    function cancelClicked() {
        pageObject.showAlert(column, qsTr("unsaved changes. continue?"))
    }

    onChildDestroyed: {
        modalityItem.state = ""
        privateProps.pendingModality = -1
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

    ControlTemperature {
        id: fixedItem
        text: (dataModel.temperature / 10).toFixed(1) + qsTr("°C")
    }

    MenuItem {
        id: modalityItem
        hasChild: true
        name: qsTr("modes")
        anchors.top: fixedItem.bottom
        height: visible ? 50 : 0
        // we can change mode on 99 zones central units, so make mode menu visible
        visible: is99zones

        onClicked: {
            column.loadColumn(thermalControlledProbeModalities, modalityItem.name, dataModel)
            if (modalityItem.state == "")
                modalityItem.state =  "selected"
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.top: modalityItem.bottom
    }

    Component {
        id: offComponent
        ButtonOkCancel {
            // a trick to avoid wrong menu column height computation
            visible: is99zones
            onVisibleChanged: if (!visible) height = 0
            onCancelClicked: column.cancelClicked()
            onOkClicked: column.okClicked()
        }
    }

    Component {
        id: antifreezeComponent
        ButtonOkCancel {
            // a trick to avoid wrong menu column height computation
            visible: is99zones
            onVisibleChanged: if (!visible) height = 0
            onCancelClicked: column.cancelClicked()
            onOkClicked: column.okClicked()
        }
    }

    Component {
        id: autoComponent
        Column {
            id: rootAutoComponent
            property int speed

            Component.onCompleted: {
                // we want an assignment, not a binding
                rootAutoComponent.speed = isFancoil() ? column.dataModel.fancoil : 0
            }

            ControlUpDown {
                title: qsTr("fan coil speed")
                text: pageObject.names.get('FANCOIL_SPEED', rootAutoComponent.speed)
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                onDownClicked: {
                    if (rootAutoComponent.speed <= 1)
                        return
                    rootAutoComponent.speed -= 1
                }
                onUpClicked: {
                    if (rootAutoComponent.speed >= 4)
                        return
                    rootAutoComponent.speed += 1
                }
            }

            ButtonOkCancel {
                onCancelClicked: {
                    rootAutoComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    column.dataModel.fancoil = rootAutoComponent.speed
                    column.okClicked()
                }
            }
        }
    }

    Component {
        id: manualComponent
        Column {
            id: rootManualComponent
            property int setpoint
            property int speed

            ControlMinusPlus {
                title: qsTr("temperature set")
                text: setpoint / 10 + qsTr("°C")
                changeable: is99zones
                onMinusClicked: rootManualComponent.setpoint -= 5
                onPlusClicked: rootManualComponent.setpoint += 5
            }

            ControlUpDown {
                title: qsTr("fan coil speed")
                text: pageObject.names.get('FANCOIL_SPEED', rootManualComponent.speed)
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                onDownClicked: {
                    if (rootManualComponent.speed <= 1)
                        return
                    rootManualComponent.speed -= 1
                }
                onUpClicked: {
                    if (rootManualComponent.speed >= 4)
                        return
                    rootManualComponent.speed += 1
                }
            }

            ButtonOkCancel {
                onCancelClicked: {
                    setpoint = dataModel.setpoint
                    rootManualComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    column.dataModel.fancoil = rootManualComponent.speed
                    dataModel.setpoint = setpoint
                    column.okClicked()
                }
            }

            Component.onCompleted: {
                rootManualComponent.setpoint = dataModel.setpoint // we want an assignment, not a binding
                rootManualComponent.speed = isFancoil() ? column.dataModel.fancoil : 0
            }
            Connections {
                target: dataModel
                onSetpointChanged: {
                    rootManualComponent.setpoint = setpoint
                }
            }
        }
    }
}

