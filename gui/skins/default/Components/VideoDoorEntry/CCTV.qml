import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    FilterListModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: model.count * 50
        delegate: MenuItemDelegate {
            itemObject: extPlaceModel.getObject(index)
            selectOnClick: false
            editable: true
            onDelegateClicked: {
                cctvModel.getObject(0).cameraOn(itemObject.where)
            }
        }
        FilterListModel {
            id: extPlaceModel
            source: cctvModel.getObject(0).externalPlaces
        }

        model: extPlaceModel

        onCurrentPageChanged: column.closeChild()
    }
}
