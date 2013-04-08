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
        closeColumn()
    }

    function cancelClicked() {
        closeColumn()
    }

    onChildDestroyed: {
        modalityItem.isSelected = false
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
        case ThermalControlledProbe.Manual:
            itemLoader.setComponent(manualComponent)
            break
        case ThermalControlledProbe.Off:
        case ThermalControlledProbe.Antifreeze:
        case ThermalControlledProbe.Auto:
            itemLoader.setComponent(automaticComponent)
            break
        case ThermalControlledProbe.Unknown:
            return
        }
        modalityItem.description = pageObject.names.get('PROBE_STATUS', modality)
    }

    Component.onCompleted: modalitySelected(dataModel.probeStatus)

    Column {
        ControlTemperature {
            id: fixedItem
            text: (dataModel.temperature / 10).toFixed(1) + "°C"
        }

        MenuItem {
            id: modalityItem
            hasChild: true
            name: qsTr("modes")
            height: visible ? 50 : 0
            // we can change mode on 99 zones central units, so make mode menu visible
            visible: is99zones

            onTouched: {
                if (!modalityItem.isSelected)
                    modalityItem.isSelected = true
                var m = privateProps.pendingModality
                if (m === -1)
                    m = column.dataModel.probeStatus
                column.loadColumn(thermalControlledProbeModalities, modalityItem.name, dataModel, {"idx": m})
            }
        }

        AnimatedLoader {
            id: itemLoader
            width: modalityItem.width
        }
    }

    Component {
        id: automaticComponent

        Column {
            id: rootAutomaticComponent
            property int speed

            ControlLeftRightWithTitle {
                title: qsTr("fancoil speed")
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                text: pageObject.names.get('FANCOIL_SPEED', rootAutomaticComponent.speed)
                onLeftClicked: {
                    if (rootAutomaticComponent.speed <= dataModel.fancoilMinValue)
                        return
                    rootAutomaticComponent.speed -= 1
                }
                onRightClicked: {
                    if (rootAutomaticComponent.speed >= dataModel.fancoilMaxValue)
                        return
                    rootAutomaticComponent.speed += 1
                }

                Component.onCompleted: {
                    // we want an assignment, not a binding
                    rootAutomaticComponent.speed = isFancoil() ? column.dataModel.fancoil : 0
                }
                Connections {
                    target: isFancoil() ? column.dataModel : null
                    onFancoilChanged: rootAutomaticComponent.speed = column.dataModel.fancoil
                }
            }

            ButtonOkCancel {
                // a trick to avoid wrong menu column height computation
                visible: is99zones || isFancoil()
                onCancelClicked: {
                    if (isFancoil())
                        rootAutomaticComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    if (isFancoil())
                        column.dataModel.fancoil = rootAutomaticComponent.speed
                    if (dataModel.probeStatus !== privateProps.pendingModality) {
                        dataModel.probeStatus = privateProps.pendingModality
                    }
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
                text: (setpoint / 10).toFixed(1) + "°C"
                changeable: is99zones
                onMinusClicked: {
                    if (rootManualComponent.setpoint - 5 < column.dataModel.minimumManualTemperature)
                        return
                    rootManualComponent.setpoint -= 5
                }
                onPlusClicked: {
                    if (rootManualComponent.setpoint + 5 > column.dataModel.maximumManualTemperature)
                        return
                    rootManualComponent.setpoint += 5
                }
            }

            ControlLeftRightWithTitle {
                title: qsTr("fancoil speed")
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                text: pageObject.names.get('FANCOIL_SPEED', rootManualComponent.speed)
                onLeftClicked: {
                    if (rootManualComponent.speed <= dataModel.fancoilMinValue)
                        return
                    rootManualComponent.speed -= 1
                }
                onRightClicked: {
                    if (rootManualComponent.speed >= dataModel.fancoilMaxValue)
                        return
                    rootManualComponent.speed += 1
                }
            }

            ButtonOkCancel {
                onCancelClicked: {
                    setpoint = dataModel.setpoint
                    if (isFancoil())
                        rootManualComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    if (isFancoil())
                        column.dataModel.fancoil = rootManualComponent.speed
                    dataModel.setpoint = setpoint // sets manual mode, too
                    column.okClicked()
                }
            }

            Component.onCompleted: {
                rootManualComponent.setpoint = dataModel.setpoint // we want an assignment, not a binding
                rootManualComponent.speed = isFancoil() ? column.dataModel.fancoil : 0
            }
            Connections {
                target: isFancoil() ? column.dataModel : null
                onFancoilChanged: rootManualComponent.speed = column.dataModel.fancoil
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

