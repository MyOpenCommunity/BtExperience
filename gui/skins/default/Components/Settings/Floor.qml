import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    function targetsKnown() {
        return {
            "Floor": privateProps.openFloorMenu,
        }
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    QtObject {
        id: privateProps
        function openFloorMenu(navigationData) {
            // we only have the floorUii so we need to find the C++ object
            var floorUii = navigationData[0]
            var floor
            for (var i = 0; i < floorsModel.count; i++) {
                floor = floorsModel.getObject(i)
                if (floor.uii === floorUii)
                    break
            }

            // for now change the navigationData, later we'll see
            navigationData.shift()
            pageObject.navigationData = navigationData

            var absIndex = floorsModel.getAbsoluteIndexOf(floor)
            if (absIndex === -1)
                return NavigationConstants.NAVIGATION_FLOOR_NOT_FOUND
            paginator.openDelegate(absIndex, paginator.openColumn)
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }
    }

    MediaModel {
        id: floorsModel
        source: myHomeModels.floors
    }

    PaginatorList {
        id: paginator
        currentIndex: -1

        function openColumn(itemObject) {
            column.loadColumn(roomsItems, itemObject.description, itemObject, {"floorUii": itemObject.uii})
        }

        delegate: MenuItemDelegate {
            itemObject: floorsModel.getObject(index)
            name: itemObject.description
            hasChild: true
            onClicked: openColumn(itemObject)
        }

        model: floorsModel
    }

    Component {
        id: roomsItems
        RoomsItems {}
    }
}
