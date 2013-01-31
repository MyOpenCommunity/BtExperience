import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack
import "../../js/navigationconstants.js" as NavigationConstants

MenuColumn {
    id: column

    property int floorUii

    function targetsKnown() {
        return {
            "Room": privateProps.openRoomMenu,
        }
    }

    MediaModel {
        id: roomsModel
        source: myHomeModels.rooms
        containers: [floorUii]
    }

    onChildDestroyed: paginator.currentIndex = -1

    Column {
        PaginatorList {
            id: paginator
            function openColumn(itemObject) {
                column.loadColumn(modifyRoom, itemObject.description, itemObject)
            }

            delegate: MenuItemDelegate {
                itemObject: roomsModel.getObject(index)
                name: itemObject.description
                hasChild: true
                onClicked: openColumn(itemObject)
            }
            model: roomsModel
        }
    }

    QtObject {
        id: privateProps

        function openRoomMenu(navigationData) {
            var absIndex = roomsModel.getAbsoluteIndexOf(navigationData[0])
            if (absIndex === -1)
                return NavigationConstants.NAVIGATION_ROOM_NOT_FOUND
            paginator.openDelegate(absIndex, paginator.openColumn)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
    }

    Component {
        id: modifyRoom
        RoomModify {}
    }
}
