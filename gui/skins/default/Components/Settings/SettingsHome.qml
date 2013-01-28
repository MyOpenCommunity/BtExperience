import QtQuick 1.1
import Components 1.0

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
        target: global.guiSettings
        onSkinChanged: skinItem.description = pageObject.names.get('SKIN', global.guiSettings.skin)
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: paginator

        MenuItem {
            id: skinItem
            name: qsTr("skin home")
            description: pageObject.names.get('SKIN', global.guiSettings.skin)
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
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                global.guiSettings.homeBgImage = ""
                column.closeColumn()
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
}
