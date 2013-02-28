import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    BtObjectsMapping { id: mapping }

    SystemsModel { id: thermalRegulation; systemId: Container.IdAirConditioning }
    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario},
            {objectId: ObjectInterface.IdSplitBasicGenericCommandGroup},
            {objectId: ObjectInterface.IdSplitAdvancedGenericCommandGroup},
        ]
        containers: [thermalRegulation.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            selectOnClick: itemObject.objectId === ObjectInterface.IdSplitBasicScenario ||
                           itemObject.objectId === ObjectInterface.IdSplitAdvancedScenario
            description: Script.description(itemObject)
            hasChild: Script.hasChild(itemObject)
            editable: true
            onDelegateClicked: {
                if (itemObject.objectId === ObjectInterface.IdSplitBasicScenario ||
                        itemObject.objectId === ObjectInterface.IdSplitAdvancedScenario)
                    column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
                else
                    itemObject.apply()
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }
}
