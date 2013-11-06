/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
        id: roomLinksModel
        source: myHomeModels.objectLinks
    }

    MediaModel {
        id: allRoomsModel
        source: myHomeModels.rooms
        containers: [floorUii]
    }

    MediaModel {
        id: floorsModel
        source: myHomeModels.floors
    }

    MediaModel {
        id: roomsModel
        source: myHomeModels.rooms
        containers: [floorUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    Column {
        MenuItem {
            name: qsTr("Add Room")
            enabled: roomsModel.count < 7
            onTouched: {
                if (privateProps.currentIndex !== 1) {
                    privateProps.currentIndex = 1
                    if (column.child)
                        column.closeChild()
                    paginator.currentIndex = -1
                }
                pageObject.installPopup(popupAddRoom)
            }
            Component {
                id: popupAddRoom
                FavoriteEditPopup {
                    title: qsTr("Insert new room name")
                    topInputLabel: qsTr("New Name:")
                    topInputText: ""
                    bottomVisible: false

                    function okClicked() {
                        myHomeModels.createRoom(floorUii, topInputText)
                    }
                }
            }
        }

        MenuItem {
            name: qsTr("Delete Floor")
            onTouched: {
                if (privateProps.currentIndex !== 2) {
                    privateProps.currentIndex = 2
                    if (column.child)
                        column.closeChild()
                    paginator.currentIndex = -1
                }
                pageObject.installPopup(deleteDialog, {"item": floorUii})
            }
            Component {
                id: deleteDialog

                TextDialog {
                    property variant item

                    title: qsTr("Confirm operation")
                    text: qsTr("Do you want to permanently delete the floor, all contained rooms and all associated information?")

                    function okClicked() {
                        for (var i = 0; i < allRoomsModel.count; ++i) {
                            var r = allRoomsModel.getObject(i)
                            roomLinksModel.containers = [r.uii]
                            for (var j = 0; j < roomLinksModel.count; ++j) {
                                var l = roomLinksModel.getObject(j)
                                roomLinksModel.remove(l)
                            }
                            r.containerUii = -1
                            allRoomsModel.remove(r)
                        }
                        for (var i = 0; i < floorsModel.count; ++i) {
                            var f = floorsModel.getObject(i)
                            if (f.uii === floorUii)
                                floorsModel.remove(f)
                        }
                        global.floorIndex = 0
                        column.closeColumn()
                    }
                }
            }
        }

        PaginatorList {
            id: paginator

            function openColumn(itemObject) {
                privateProps.currentIndex = -1
                column.loadColumn(modifyRoom, itemObject.description, itemObject)
            }

            elementsOnPage: elementsOnMenuPage - 2
            delegate: MenuItemDelegate {
                itemObject: roomsModel.getObject(index)
                name: itemObject.description
                hasChild: true
                onDelegateTouched: openColumn(itemObject)
            }
            model: roomsModel
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1

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
