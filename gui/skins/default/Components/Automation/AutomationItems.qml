import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/MenuItem.js" as MenuItem


MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    BtObjectsMapping { id: mapping }
    SystemsModel { id: systemsModel; systemId: Container.IdAutomation }

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
            editable: true
            status: MenuItem.status(itemObject)
            hasChild: MenuItem.hasChild(itemObject)
            boxInfoState: MenuItem.boxInfoState(itemObject)
            boxInfoText: MenuItem.boxInfoText(itemObject)
            onClicked: {
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, objectModel.getObject(model.index))
            }
        }
        model: objectModel
        onCurrentPageChanged: column.closeChild()
    }
}
