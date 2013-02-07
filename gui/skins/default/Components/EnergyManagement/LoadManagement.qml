import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as MenuItem


MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdLoadControl }

    ObjectModel {
        id: listModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadWithControlUnit},
            {objectId: ObjectInterface.IdLoadWithoutControlUnit}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    Component { id: appliance; Appliance {} }

    PaginatorList {
        id: paginator

        currentIndex: -1
        onCurrentPageChanged: element.closeChild()
        model: listModel

        delegate: MenuItemDelegate {
            itemObject: listModel.getObject(index)
            name: itemObject.name
            status: MenuItem.status(itemObject)
            description: MenuItem.description(itemObject)
            boxInfoState: MenuItem.boxInfoState(itemObject)
            boxInfoText: MenuItem.boxInfoText(itemObject)
            hasChild: true
            onDelegateClicked: element.loadColumn(appliance, itemObject.name, itemObject)
            Component.onCompleted: {
                itemObject.requestLoadStatus()
                itemObject.requestConsumptionUpdateStart()
            }
            Component.onDestruction: itemObject.requestConsumptionUpdateStop()
        }
    }
}
