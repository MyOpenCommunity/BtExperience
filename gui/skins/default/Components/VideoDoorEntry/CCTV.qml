import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    SystemsModel {id: systemsModel; systemId: Container.IdVideoDoorEntry }
    ObjectModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: extPlaceModel.getObject(index)
            selectOnClick: false
            editable: true
            onDelegateClicked: {
                cctvModel.getObject(0).cameraOn(itemObject)
            }
        }
        ObjectModel {
            id: extPlaceModel
            containers: [systemsModel.systemUii]
            source: cctvModel.getObject(0).externalPlaces
            range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
        }

        model: extPlaceModel

        onCurrentPageChanged: column.closeChild()
    }
}
