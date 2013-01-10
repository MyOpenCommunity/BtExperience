import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

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
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenClose ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenCloseSafe ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDown ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDownSafe)
                    return -1
                return itemObject.active === true ? 1 : 0
            }
            hasChild: true
            boxInfoState: {
                if (itemObject.objectId === ObjectInterface.IdAutomationGroup2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationVDE ||
                        itemObject.objectId === ObjectInterface.IdAutomationDoor ||
                        itemObject.objectId === ObjectInterface.IdAutomation2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenClose ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenCloseSafe ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDown ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDownSafe)
                    return ""
                // Automation3
                else return ""
            }
            boxInfoText: {
                if (itemObject.objectId === ObjectInterface.IdAutomationGroup2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationVDE ||
                        itemObject.objectId === ObjectInterface.IdAutomationDoor ||
                        itemObject.objectId === ObjectInterface.IdAutomation2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenClose ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3OpenCloseSafe ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDown ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3UpDownSafe)
                    return ""
                // Automation3
                // if (itemObject.active) return itemObject.percentage + "%"
                else return ""
            }

            onClicked: {
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, objectModel.getObject(model.index))
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }
}
