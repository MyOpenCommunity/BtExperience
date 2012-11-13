import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    property int floorUii

    MediaModel {
        id: roomsModel
        source: myHomeModels.rooms
        containers: [floorUii]
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Column {
        PaginatorList {
            id: paginator
            delegate: MenuItemDelegate {
                itemObject: roomsModel.getObject(index)
                name: itemObject.description
                hasChild: true
                onClicked: {
                    privateProps.currentIndex = -1
                    column.loadColumn(modifyRoom, itemObject.description)
                }
            }
            model: roomsModel
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    Component {
        id: addRoom
        Item {}
    }

    Component {
        id: modifyRoom
        RoomModify {}
    }
}
