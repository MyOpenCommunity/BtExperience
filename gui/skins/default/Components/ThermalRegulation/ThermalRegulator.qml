import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            description: privateProps.getDescription(itemObject, itemObject.currentModalityId, itemObject.probeStatus, itemObject.localProbeStatus)
            hasChild: true
            onClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
            boxInfoState: privateProps.getBoxInfoState(itemObject, itemObject.currentModalityId)
            boxInfoText: privateProps.getBoxInfoText(itemObject, itemObject.currentModalityId, itemObject.temperature)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    QtObject {
        id: privateProps

        // some helpers
        function isControlledProbe(itemObject) {
            return (itemObject.objectId === ObjectInterface.IdThermalControlledProbe ||
                    itemObject.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
        }

        function isModeManual(mode) {
            return (mode === ThermalControlUnit.IdManual ||
                    mode === ThermalControlUnit.IdTimedManual)
        }

        function isProbeOffsetZero(itemObject) {
            return (itemObject.localOffset === 0)
        }

        function isCentral99Zones(itemObject) {
            return (itemObject.centralType === ThermalControlledProbe.CentralUnit99Zones)
        }

        function getOffsetRepresentation(offset) {
            // we need to output a '+' sign for positive values
            var r = offset > 0 ? "+" : ""
            r += offset
            return r
        }

        // this function computes a description for CU and ZONES menu items (it does not consider
        // the measured temperature because is managed by getBoxInfoText function)
        // the possible cases are:
        // CU99Z:
        //      - in manual mode: set point, offset, mode
        //      - otherwise: mode, offset
        // CU4Z:
        //      - in manual mode: set point, offset, mode
        //      - otherwise: mode, offset
        // Z99Z:
        //      - if CU or Z in manual mode: set point, offset, mode
        //      - otherwise: mode, offset
        // Z4Z:
        //      - in manual mode: set point, offset
        //      - otherwise: offset
        function getDescription(itemObject, currentModalityId, probeStatus, localProbeStatus) {
            var descr = "---"

            if (isControlledProbe(itemObject)) {
                // it is a probe
                descr = ""

                // show 'protection' or 'off'
                if (localProbeStatus === ThermalControlledProbe.Antifreeze ||
                        localProbeStatus === ThermalControlledProbe.Off) {
                    return pageObject.names.get('PROBE_STATUS', localProbeStatus)
                }
                else if (probeStatus === ThermalControlledProbe.Antifreeze ||
                         probeStatus === ThermalControlledProbe.Off) {
                    return pageObject.names.get('PROBE_STATUS', probeStatus)
                }

                // no special state, show setpoint (if in manual) and local offset
                if (probeStatus === ThermalControlledProbe.Manual) {
                    descr += (itemObject.setpoint / 10).toFixed(1) + qsTr("°C")
                }
                if (!isProbeOffsetZero(itemObject))
                    descr += " " + getOffsetRepresentation(itemObject.localOffset)
                descr += " " + pageObject.names.get('PROBE_STATUS', probeStatus)
            }
            else {
                // it is a CU (99Z or 4Z are the same)
                descr = ""
                if (isModeManual(probeStatus)) {
                    descr += " " + itemObject.setpoint
                    if (!isProbeOffsetZero(itemObject))
                        if (itemObject.localOffset)
                            descr += " " + getOffsetRepresentation(itemObject.localOffset)
                }
                if (currentModalityId !== undefined && currentModalityId >= 0)
                    descr += pageObject.names.get('CENTRAL_STATUS', currentModalityId)
                if (!isModeManual(probeStatus))
                    if (!isProbeOffsetZero(itemObject))
                        if (itemObject.localOffset)
                            descr += " " + getOffsetRepresentation(itemObject.localOffset)
            }

            return descr
        }

        function getBoxInfoState(itemObject, currentModalityId) {
            // we need to show the measured temperature for probes and in manual mode
            if (itemObject.objectId === ObjectInterface.IdThermalControlledProbe ||
                    itemObject.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
                return "info"
            if (itemObject.probeStatus === ThermalControlledProbe.Manual ||
                    currentModalityId === ThermalControlUnit.IdManual)
                return "info"
            return ""
        }

        function getBoxInfoText(itemObject, currentModalityId, temperature) {
            // formats the measured temperature in the right format
            var t = 0
            if (itemObject.objectId === ObjectInterface.IdThermalControlledProbe ||
                    itemObject.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
                t = (temperature / 10).toFixed(1)
            if (currentModalityId === ThermalControlUnit.IdManual) {
                t = (itemObject.currentModality.temperature / 10).toFixed(1)
            }
            if (t > 0)
                return t + qsTr("°C")
            return "---"
        }
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlUnit4, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbe, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil, objectKey: column.dataModel.objectKey}
        ]
    }
}

