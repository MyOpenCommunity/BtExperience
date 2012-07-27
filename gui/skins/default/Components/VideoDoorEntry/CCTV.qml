import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

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
                cctvModel.getObject(0).cameraOn(itemObject.where)
            }
        }
        ObjectModel {
            id: extPlaceModel
            source: cctvModel.getObject(0).externalPlaces
        }

        model: extPlaceModel

        onCurrentPageChanged: column.closeChild()
    }
}
