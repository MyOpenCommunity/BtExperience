import QtQuick 1.1
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    Component {
        id: skin
        Skin {}
    }

    Component {
        id: quicklinks
        SettingsHomeQuicklinks {}
    }

    function alertOkClicked() {
        skinItem.description = pageObject.names.get('SKIN', privateProps.skin);
        global.guiSettings.skin = privateProps.skin
        Stack.backToHome()
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        property int skin: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    onChildLoaded: {
        if (child.skinChanged)
            child.skinChanged.connect(skinChanged)
    }

    function skinChanged(value) {
        // TODO assign to a model property
        //privateProps.model.TextLanguage = value;
        // TODO remove when model is implemented
        privateProps.skin = value
        pageObject.showAlert(column, qsTr("Pressing ok will cause a device reboot as soon as possible.\nPlease, do not use the touch till it is restarted.\nContinue?"))
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300

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
            name: qsTr("Modify background image")
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(settingsImageBrowser, qsTr("Background image"), column.dataModel, {homeCustomization: true})
            }
        }

        MenuItem {
            name: qsTr("Reset background image")
            isSelected: privateProps.currentIndex === 3
            onClicked: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                global.guiSettings.homeBgImage = ""
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
