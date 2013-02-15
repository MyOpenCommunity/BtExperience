import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    BtObjectsMapping { id: mapping }

    SystemsModel { id: thermalRegulation; systemId: Container.IdAirConditioning }
    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario}
        ]
        containers: [thermalRegulation.systemUii]
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)
            description: (itemObject.temperature / 10).toFixed() + "°C"
            hasChild: true
            onClicked: {
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }
}
