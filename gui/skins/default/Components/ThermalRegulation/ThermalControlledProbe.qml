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
        pageObject.showAlert(column, qsTr("unsaved changes. continue?"))
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
        anchors.top: modalityItem.bottom
    }

    Component {
        id: offComponent

        Column {
            id: rootOffComponent
            ControlLeftRightWithTitle {
                property int speed
                title: qsTr("fancoil speed")
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                text: pageObject.names.get('FANCOIL_SPEED', rootOffComponent.speed)
                onLeftClicked: {
                    if (rootOffComponent.speed <= dataModel.fancoilMinValue)
                        return
                    rootOffComponent.speed -= 1
                }
                onRightClicked: {
                    if (rootOffComponent.speed >= dataModel.fancoilMaxValue)
                        return
                    rootOffComponent.speed += 1
                }

                Component.onCompleted: {
                    // we want an assignment, not a binding
                    rootOffComponent.speed = isFancoil() ? column.dataModel.fancoil : 0
                }
                Connections {
                    target: isFancoil() ? column.dataModel : null
                    onFancoilChanged: rootOffComponent.speed = column.dataModel.fancoil
                }
            }

            ButtonOkCancel {
                // a trick to avoid wrong menu column height computation
                visible: is99zones
                onVisibleChanged: if (!visible) height = 0
                onCancelClicked: {
                    if (isFancoil())
                        rootOffComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    if (isFancoil())
                        column.dataModel.fancoil = rootOffComponent.speed
                    if (dataModel.probeStatus !== privateProps.pendingModality) {
                        dataModel.probeStatus = privateProps.pendingModality
                    }
                    column.okClicked()
                }
            }
        }
    }

    Component {
        id: antifreezeComponent
        Column {
            id: rootAntifreezeComponent
            ControlLeftRightWithTitle {
                property int speed
                title: qsTr("fancoil speed")
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                text: pageObject.names.get('FANCOIL_SPEED', rootAntifreezeComponent.speed)
                onLeftClicked: {
                    if (rootAntifreezeComponent.speed <= dataModel.fancoilMinValue)
                        return
                    rootAntifreezeComponent.speed -= 1
                }
                onRightClicked: {
                    if (rootAntifreezeComponent.speed >= dataModel.fancoilMaxValue)
                        return
                    rootAntifreezeComponent.speed += 1
                }

                Component.onCompleted: {
                    // we want an assignment, not a binding
                    rootAntifreezeComponent.speed = isFancoil() ? column.dataModel.fancoil : 0
                }
                Connections {
                    target: isFancoil() ? column.dataModel : null
                    onFancoilChanged: rootAntifreezeComponent.speed = column.dataModel.fancoil
                }
            }

            ButtonOkCancel {
                // a trick to avoid wrong menu column height computation
                visible: is99zones
                onVisibleChanged: if (!visible) height = 0
                onCancelClicked: {
                    if (isFancoil())
                        rootAntifreezeComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    if (isFancoil())
                        column.dataModel.fancoil = rootAntifreezeComponent.speed
                    if (dataModel.probeStatus !== privateProps.pendingModality) {
                        dataModel.probeStatus = privateProps.pendingModality
                    }
                    column.okClicked()
                }
            }
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
            Connections {
                target: isFancoil() ? column.dataModel : null
                onFancoilChanged: rootAutoComponent.speed = column.dataModel.fancoil
            }

            ControlLeftRightWithTitle {
                title: qsTr("fancoil speed")
                // fancoil panel is visible only for fancoil probes
                visible: isFancoil()
                text: pageObject.names.get('FANCOIL_SPEED', rootAutoComponent.speed)
                onLeftClicked: {
                    if (rootAutoComponent.speed <= dataModel.fancoilMinValue)
                        return
                    rootAutoComponent.speed -= 1
                }
                onRightClicked: {
                    if (rootAutoComponent.speed >= dataModel.fancoilMaxValue)
                        return
                    rootAutoComponent.speed += 1
                }
            }

            ButtonOkCancel {
                onCancelClicked: {
                    if (isFancoil())
                        rootAutoComponent.speed = column.dataModel.fancoil
                    column.cancelClicked()
                }
                onOkClicked: {
                    if (isFancoil())
                        column.dataModel.fancoil = rootAutoComponent.speed
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
                text: (setpoint / 10).toFixed(1) + qsTr("°C")
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

