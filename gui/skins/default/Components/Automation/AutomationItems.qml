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
            status: {
                if (itemObject.objectId === ObjectInterface.IdAutomationGroup2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationVDE ||
                        itemObject.objectId === ObjectInterface.IdAutomationDoor ||
                        itemObject.objectId === ObjectInterface.IdAutomation3UpDown ||
                        itemObject.objectId === ObjectInterface.IdAutomation3UpDownSafe ||
                        itemObject.objectId === ObjectInterface.IdAutomation3OpenClose ||
                        itemObject.objectId === ObjectInterface.IdAutomation3OpenCloseSafe ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenClose ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDown )
                    return -1
                return MenuItem.status(itemObject)
            }
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
