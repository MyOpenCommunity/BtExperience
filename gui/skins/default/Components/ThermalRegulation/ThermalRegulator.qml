import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            description: Script.description(itemObject)
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

