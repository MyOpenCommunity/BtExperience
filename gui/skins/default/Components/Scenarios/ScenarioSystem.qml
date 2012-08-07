import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    BtObjectsMapping { id: mapping }

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

}
