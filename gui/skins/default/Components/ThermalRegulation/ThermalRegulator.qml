import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.ThermalRegulation 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    Component { id: thermalControlUnit; ThermalControlUnit {} }
    Component { id: thermalControlledProbe; ThermalControlledProbe {} }

    SystemsModel { id: systemsModel; systemId: Container.IdThermalRegulation }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlUnit4, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbe, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil, objectKey: column.dataModel.objectKey}
        ]
        containers: [systemsModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        currentIndex: -1

        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            description: Script.description(itemObject)
            hasChild: Script.hasChild(itemObject)
            onClicked: {
                var oid = itemObject.objectId
                if (oid === ObjectInterface.IdThermalControlUnit99)
                    column.loadColumn(thermalControlUnit, itemObject.name, itemObject)
                if (oid === ObjectInterface.IdThermalControlUnit4)
                    column.loadColumn(thermalControlUnit, itemObject.name, itemObject)
                if (oid === ObjectInterface.IdThermalControlledProbe)
                    column.loadColumn(thermalControlledProbe, itemObject.name, itemObject)
                if (oid === ObjectInterface.IdThermalControlledProbeFancoil)
                    column.loadColumn(thermalControlledProbe, itemObject.name, itemObject)
            }
            boxInfoState: Script.boxInfoState(itemObject)
            boxInfoText: Script.boxInfoText(itemObject)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }
}

