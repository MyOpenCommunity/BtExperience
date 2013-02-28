import QtQuick 1.1
import BtObjects 1.0
import "../../js/Stack.js" as Stack
import Components 1.0

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
