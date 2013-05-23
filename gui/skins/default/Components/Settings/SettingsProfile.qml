import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

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
            name: qsTr("Add Quicklink")
            isSelected: privateProps.currentIndex === 3
            onTouched: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                Stack.pushPage("AddQuicklink.qml", {"profile": column.dataModel})
            }
        }

        MenuItem {
            name: qsTr("Restore background image")
            isSelected: privateProps.currentIndex === 4
            onTouched: {
                privateProps.currentIndex = -1
                pageObject.installPopup(okCancelDialogRestore, {"item": column.dataModel})
            }
        }

        MenuItem {
            name: qsTr("Delete Profile")
            isSelected: privateProps.currentIndex === 5
            onTouched: {
                privateProps.currentIndex = -1
                pageObject.installPopup(deleteDialog, {"item": column.dataModel})
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

    ObjectModel {
        id: profilesModel
        source: myHomeModels.profiles
    }

    MediaModel {
        id: userNotes
        source: myHomeModels.notes
    }

    MediaModel {
        id: mediaLinks
        source: myHomeModels.mediaLinks
    }

    Component {
        id: deleteDialog

        TextDialog {
            property variant item

            title: qsTr("Confirm operation")
            text: qsTr("Do you want to permanently delete the profile and all associated information?")

            function okClicked() {
                userNotes.containers = [item.uii]
                for (var i = 0; i < userNotes.count; ++i) {
                    var n = userNotes.getObject(i)
                    userNotes.remove(n)
                }
                mediaLinks.containers = [item.uii]
                for (var i = 0; i < mediaLinks.count; ++i) {
                    var l = mediaLinks.getObject(i)
                    mediaLinks.remove(l)
                }
                profilesModel.remove(item)
                column.closeColumn()
            }
        }
    }

    Component {
        id: okCancelDialogRestore

        TextDialog {
            property variant item

            title: qsTr("Confirm operation")
            text: qsTr("Do you want to restore background to default value?")

            function okClicked() {
                item.image = ""
                column.closeColumn()
            }
        }
    }
}
