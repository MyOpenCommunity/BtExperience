import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script


MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    BtObjectsMapping { id: mapping }

    SystemsModel { id: thermalRegulation; systemId: Container.IdThermalRegulation }
    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalNonControlledProbe}
        ]
        containers: [thermalRegulation.systemUii]
    }

    PaginatorList {
        id: itemList

        currentIndex: -1
        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            onClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
            description: Script.description(itemObject)
            hasChild: Script.hasChild(itemObject)
            boxInfoState: Script.boxInfoState(itemObject)
            boxInfoText: Script.boxInfoText(itemObject)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }
}
