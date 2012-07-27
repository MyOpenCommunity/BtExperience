import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)
            hasChild: true
            onClicked:
                column.loadColumn(
                    mapping.getComponent(itemObject.objectId),
                    itemObject.name,
                    itemObject)
        }

        model: objectModel
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSimpleScenario},
            {objectId: ObjectInterface.IdScenarioModule},
            {objectId: ObjectInterface.IdScheduledScenario},
            {objectId: ObjectInterface.IdAdvancedScenario},
        ]
        range: itemList.computePageRange(itemList.currentPage, itemList.elementsOnPage)
    }

/*
    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)
            hasChild: true
            onClicked:
                column.loadColumn(
                    mapping.getComponent(itemObject.objectId),
                    itemObject.name,
                    itemObject)
        }

        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }

    ObjectModel {
        id: objectModel
        source: myHomeModels.myHomeObjects
        containers: [Container.IdScenarios]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
    */
}
