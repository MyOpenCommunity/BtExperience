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
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(settingsImageBrowser, qsTr("Card image"), column.dataModel, {isCard: true})
            }
        }

        MenuItem {
            name: qsTr("Change background image")
            isSelected: privateProps.currentIndex === 2
            hasChild: true
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(settingsImageBrowser, qsTr("Background image"), column.dataModel)
            }
        }

        MenuItem {
            name: qsTr("Add Quicklink")
            isSelected: privateProps.currentIndex === 3
            onClicked: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                Stack.pushPage("AddQuicklink.qml", {"profile": column.dataModel})
            }
        }

        MenuItem {
            name: qsTr("Restore background image")
            isSelected: privateProps.currentIndex === 4
            onClicked: {
                privateProps.currentIndex = -1
                pageObject.installPopup(okCancelDialogRestore, {"item": column.dataModel})
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
