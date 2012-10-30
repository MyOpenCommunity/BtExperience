import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    SystemsModel {id: systemsModel; systemId: Container.IdVideoDoorEntry }
    ObjectModel {
        id: modelList
        filters: [{objectId: ObjectInterface.IdIntercom}]
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            editable: true
            itemObject: extPlaceModel.getObject(index)
            selectOnClick: false
            hasChild: true
            onDelegateClicked: {
                column.loadColumn(talk, itemObject.name, modelList.getObject(0), {"where": itemObject.where})
            }
        }

        ObjectModel {
            id: extPlaceModel
            containers: [systemsModel.systemUii]
            source: modelList.getObject(0).externalPlaces
            range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
        }

        model: extPlaceModel

        onCurrentPageChanged: column.closeChild()
    }

    Component {
        id: talk
        Talk {}
    }
}
