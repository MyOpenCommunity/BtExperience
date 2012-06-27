import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    width: 212
    height: 250

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

        function isCentralModeManual(probeStatus) {
            return (probeStatus === ThermalControlledProbe.Manual)
        }

        function isProbeModeManual(localProbeStatus) {
            return (localProbeStatus === ThermalControlledProbe.Manual)
        }

        function isProbeOffsetSet(itemObject) {
            return (itemObject.localOffset !== 0)
        }

        function isCentral99Zones(itemObject) {
            return (itemObject.centralType === ThermalControlledProbe.CentralUnit99Zones)
        }


        function getDescription(itemObject, currentModalityId, probeStatus, localProbeStatus) {
            var descr = "--"

            if (isControlledProbe(itemObject)) {
                descr = ""
                if (isCentralModeManual(probeStatus) || isProbeModeManual(localProbeStatus)) {
                    descr += " " + itemObject.setpoint
                    if (isProbeOffsetSet(itemObject))
                        descr += " " + itemObject.localOffset
                }
                if (isCentral99Zones(itemObject))
                    descr += " " + pageObject.names.get('PROBE_STATUS', localProbeStatus)
                if (!isCentralModeManual(probeStatus)) {
                    descr += " " + itemObject.localOffset
                }
            }

            if (currentModalityId >= 0)
                descr = pageObject.names.get('CENTRAL_STATUS', currentModalityId)
            return descr
        }

        function getBoxInfoState(itemObject, currentModalityId) {
            if (itemObject.objectId === ObjectInterface.IdThermalControlledProbe ||
                    itemObject.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
                return "info"
            if (itemObject.probeStatus === ThermalControlledProbe.Manual ||
                    currentModalityId === ThermalControlUnit.IdManual)
                return "info"
            return ""
        }

        function getBoxInfoText(itemObject, currentModalityId, temperature) {
            if (itemObject.objectId === ObjectInterface.IdThermalControlledProbe ||
                    itemObject.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
                return (temperature / 10).toFixed(1) + qsTr("°C")
            if (currentModalityId === ThermalControlUnit.IdManual)
                return (itemObject.currentModality.temperature / 10).toFixed(1) + qsTr("°C")
            return ""
        }
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99},
            {objectId: ObjectInterface.IdThermalControlUnit4},
            {objectId: ObjectInterface.IdThermalControlledProbe},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil}
        ]
    }
}

