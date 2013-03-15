import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as MenuItem


MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdSupervision }

    ObjectModel {
        id: listModel

        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    Column {
        PaginatorList {
            id: paginator

            currentIndex: -1
            onCurrentPageChanged: element.closeChild()
            delegate: MenuItem {
                property variant itemObject: listModel.getObject(index)
                clickable: false
                status: MenuItem.status(itemObject)
                hasChild: MenuItem.hasChild(itemObject)
                description: MenuItem.description(itemObject)
                name: itemObject.name
                Component.onCompleted: itemObject.requestLoadStatus()
            }
            model: listModel
        }
    }
}
