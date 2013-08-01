import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack
import "../../js/MenuItem.js" as Script


MenuColumn {
    id: column

    MediaModel {
        id: roomLinksModel
        source: myHomeModels.objectLinks
    }

    MediaModel {
        id: roomsModel
        source: myHomeModels.rooms
    }

    MediaModel {
        id: linksModel
        source: myHomeModels.objectLinks
        containers: [column.dataModel.uii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
        paginator.currentIndex = -1
    }

    Column {
        MenuItem {
            name: qsTr("Change card image")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(settingsImageBrowser, qsTr("Card image"), column.dataModel, {isCard: true})
            }
        }

        MenuItem {
            name: qsTr("Change background image")
            isSelected: privateProps.currentIndex === 2
            hasChild: true
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(settingsImageBrowser, qsTr("Background image"), column.dataModel)
            }
        }

        MenuItem {
            name: qsTr("Delete room")
            isSelected: privateProps.currentIndex === 3
            onTouched: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                pageObject.installPopup(deleteDialog, {"item": column.dataModel})
            }
            Component {
                id: deleteDialog

                TextDialog {
                    property variant item

                    title: qsTr("Confirm operation")
                    text: qsTr("Do you want to permanently delete the room and all associated information?")

                    function okClicked() {
                        roomLinksModel.containers = [item.uii]
                        for (var i = 0; i < roomLinksModel.count; ++i) {
                            var l = roomLinksModel.getObject(i)
                            roomLinksModel.remove(l)
                        }
                        item.containerUii = -1
                        roomsModel.remove(item)
                        column.closeColumn()
                    }
                }
            }
        }

        MenuItem {
            name: qsTr("Add object")
            isSelected: privateProps.currentIndex === 4
            hasChild: true
            onTouched: {
                if (privateProps.currentIndex !== 4)
                    privateProps.currentIndex = 4
                column.loadColumn(objectLinkChoice, qsTr("Objectlinks list"), column.dataModel)
            }
        }

        PaginatorList {
            id: paginator

            function openColumn(itemObject, index) {
                privateProps.currentIndex = -1
                column.loadColumn(deleteRenameLink, itemObject.name, itemObject, {"index": index})
            }

            elementsOnPage: elementsOnMenuPage - 4
            delegate: MenuItemDelegate {
                itemObject: linksModel.getObject(index).btObject
                description: Script.description(itemObject)
                onDelegateTouched: openColumn(itemObject, index)
                hasChild: true
            }
            model: linksModel
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    Component {
        id: objectLinkChoice
        ObjectLinkChoice {}
    }

    Component {
        id: settingsImageBrowser
        SettingsImageBrowser {}
    }

    Component {
        id: deleteRenameLink
        SettingsObjectLink { uii: column.dataModel.uii }
    }
}
