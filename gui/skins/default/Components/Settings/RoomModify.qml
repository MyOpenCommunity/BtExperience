import QtQuick 1.1
import BtObjects 1.0
import "../../js/Stack.js" as Stack
import Components 1.0

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

    onChildDestroyed: privateProps.currentIndex = -1

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
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    Component {
        id: settingsImageBrowser
        SettingsImageBrowser {}
    }
}
