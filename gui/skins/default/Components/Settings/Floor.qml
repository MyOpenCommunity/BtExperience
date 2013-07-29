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

        property int currentIndex: -1

        function openFloorMenu(navigationData) {
            // we only have the floorUii so we need to find the C++ object
            var floorUii = navigationData.shift()
            pageObject.navigationData = navigationData

            var floor
            for (var i = 0; i < floorsModel.count; i++) {
                floor = floorsModel.getObject(i)
                if (floor.uii === floorUii)
                    break
            }

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
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Column {
        MenuItem {
            name: qsTr("Add Floor")
            enabled: floorsModel.count < 6
            onTouched: {
                if (privateProps.currentIndex !== 1) {
                    privateProps.currentIndex = 1
                    if (column.child)
                        column.closeChild()
                    paginator.currentIndex = -1
                }
                pageObject.installPopup(popupAddFloor)
            }
            Component {
                id: popupAddFloor
                FavoriteEditPopup {
                    title: qsTr("Insert new floor name")
                    topInputLabel: qsTr("New Name:")
                    topInputText: ""
                    bottomVisible: false

                    function okClicked() {
                        myHomeModels.createFloor(topInputText)
                    }
                }
            }
        }

        PaginatorList {
            id: paginator

            elementsOnPage: elementsOnMenuPage - 1
            currentIndex: -1

            function openColumn(itemObject) {
                privateProps.currentIndex = -1
                column.loadColumn(roomsItems, itemObject.description, itemObject, {"floorUii": itemObject.uii})
            }

            delegate: MenuItemDelegate {
                itemObject: floorsModel.getObject(index)
                name: itemObject.description
                hasChild: true
                onDelegateTouched: openColumn(itemObject)
            }

            model: floorsModel
        }
    }

    Component {
        id: roomsItems
        RoomsItems {}
    }
}
