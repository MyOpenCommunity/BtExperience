import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            editable: true

            status: Script.status(itemObject)

            hasChild: true
            boxInfoState: Script.boxInfoState(itemObject)
            boxInfoText: Script.boxInfoText(itemObject)

            onClicked: {
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, objectModel.getObject(model.index))
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }
    SystemsModel { id: systemsModel; systemId: Container.IdLights }

    ObjectModel {
        id: objectModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
