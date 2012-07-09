import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

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

            status: {
                if (true)
                    console.log("&&& "+itemObject.objectId+"\n")
                if (itemObject.objectId === ObjectInterface.IdAutomationGroup2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationVDE ||
                        itemObject.objectId === ObjectInterface.IdAutomationDoor ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3)
                    console.log("# "+itemObject.objectId+"\n")
                    return -1
                console.log("## "+itemObject.objectId+"\n")
                return itemObject.active === true ? 1 : 0
            }
            hasChild: true
            boxInfoState: {
                if (itemObject.objectId === ObjectInterface.IdAutomationGroup2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationVDE ||
                        itemObject.objectId === ObjectInterface.IdAutomationDoor ||
                        itemObject.objectId === ObjectInterface.IdAutomation2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3)
                    console.log("### "+itemObject.objectId+"\n")
                    return ""
                // Automation3
                console.log("#### "+itemObject.objectId+"\n")
                return "info"
            }
            boxInfoText: {
                if (itemObject.objectId === ObjectInterface.IdAutomationGroup2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationVDE ||
                        itemObject.objectId === ObjectInterface.IdAutomationDoor ||
                        itemObject.objectId === ObjectInterface.IdAutomation2 ||
                        itemObject.objectId === ObjectInterface.IdAutomationGroup3)
                    console.log("##### "+itemObject.objectId+"\n")
                    return ""
                // Automation3
                if (itemObject.active)
                    console.log("###### "+itemObject.objectId+"\n")
                    return itemObject.percentage + "%"
                console.log("####### "+itemObject.objectId+"\n")
                return "-"
            }

            onClicked: {
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, objectModel.getObject(model.index))
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: objectModel
        source: myHomeModels.myHomeObjects
        containers: [Container.IdAutomation]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
