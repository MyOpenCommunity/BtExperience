import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    MediaModel {
        id: floorsModel
        source: myHomeModels.floors
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: floorsModel.getObject(index)
            name: itemObject.description
            hasChild: true
            onClicked: column.loadColumn(roomsItems, itemObject.description, itemObject, {"floorUii": itemObject.uii})
        }

        model: floorsModel
    }

    Component {
        id: roomsItems
        RoomsItems {}
    }
}
