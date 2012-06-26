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
            description: privateProps.getDescription(itemObject.currentModalityId)
            hasChild: true
            onClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
            boxInfoState: privateProps.getBoxInfoState(itemObject, itemObject.currentModalityId)
            boxInfoText: privateProps.getBoxInfoText(itemObject, itemObject.currentModalityId)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    QtObject {
        id: privateProps

        function getDescription(currentModalityId) {
            var descr = "--"
            if (currentModalityId >= 0)
                descr = pageObject.names.get('CENTRAL_STATUS', currentModalityId)
            return descr
        }

        function getBoxInfoState(itemObject, currentModalityId) {
            if (itemObject.probeStatus === ThermalControlledProbe.Manual ||
                    currentModalityId === ThermalControlUnit.IdManual)
                return "info"
            return ""
        }

        function getBoxInfoText(itemObject, currentModalityId) {
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

