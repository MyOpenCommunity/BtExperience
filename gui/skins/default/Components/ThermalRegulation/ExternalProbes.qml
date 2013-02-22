import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script


MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    BtObjectsMapping { id: mapping }

    SystemsModel { id: thermalRegulation; systemId: Container.IdThermalRegulation }
    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalExternalProbe}
        ]
        containers: [thermalRegulation.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

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
