import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    ObjectModel {
        id: modelList
        filters: [{objectId: ObjectInterface.IdIntercom}]
    }

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: modelList.count * 50

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
            source: modelList.getObject(0).externalPlaces
        }

        model: extPlaceModel

        onCurrentPageChanged: column.closeChild()
    }

    Component {
        id: talk
        Talk {}
    }
}
