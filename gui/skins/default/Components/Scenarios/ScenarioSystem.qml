import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script


MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    BtObjectsMapping { id: mapping }
    SystemsModel { id: systemsModel; systemId: Container.IdScenarios }

    ObjectModel {
        id: objectModel

        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            hasChild: Script.hasChild(itemObject)
            editable: true
            onDelegateClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
        }
        model: objectModel
        onCurrentPageChanged: column.closeChild()
    }
}
