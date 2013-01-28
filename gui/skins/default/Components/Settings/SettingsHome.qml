import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/default.js" as Default

MenuColumn {
    id: column

    Component {
        id: skin
        SettingsSkin {}
    }

    Component {
        id: quicklinks
        SettingsHomeQuicklinks {}
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1

    }

    Connections {
        target: homeProperties
        onSkinChanged: skinItem.description = pageObject.names.get('SKIN', homeProperties.skin)
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: paginator

        MenuItem {
            id: skinItem
            name: qsTr("skin home")
            description: pageObject.names.get('SKIN', homeProperties.skin)
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(skin, name)
            }
        }

        MenuItem {
            name: qsTr("Change background image")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(settingsImageBrowser, qsTr("Background image"), column.dataModel, {homeCustomization: true})
            }
        }

        MenuItem {
            name: qsTr("Restore background image")
            isSelected: privateProps.currentIndex === 3
            onClicked: {
                privateProps.currentIndex = -1
                pageObject.installPopup(okCancelDialogRestore)
            }
        }

        MenuItem {
            name: qsTr("Quicklinks")
            isSelected: privateProps.currentIndex === 4
            hasChild: true
            onClicked: {
                if (privateProps.currentIndex !== 4)
                    privateProps.currentIndex = 4
                column.loadColumn(quicklinks, qsTr("Quicklinks"))
            }
        }
     }

    Component {
        id: settingsImageBrowser
        SettingsImageBrowser {}
    }

    Component {
        id: okCancelDialogRestore

        TextDialog {
            title: qsTr("Confirm operation")
            text: qsTr("Do you want to restore background to default value?")

            function okClicked() {
                homeProperties.homeBgImage = Default.getDefaultHomeBg()
                column.closeColumn()
            }
        }
    }
}
