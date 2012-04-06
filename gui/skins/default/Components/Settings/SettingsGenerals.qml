import QtQuick 1.1
import Components 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: model.componentFile !== ""

            onClicked: {
                if (model.componentFile !== "")
                    element.loadElement(model.componentFile, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "version"
            componentFile: "Components/Settings/SettingsVersion.qml"
        }
        ListElement {
            name: "date & time"
            componentFile: "Components/Settings/SettingsDateTime.qml"
        }
        ListElement {
            name: "network"
            componentFile: "Components/Settings/SettingsNetwork.qml"
        }
        ListElement {
            name: "display"
            componentFile: "Components/Settings/SettingsDisplay.qml"
        }
        ListElement {
            name: "international"
            componentFile: "Components/Settings/SettingsInternational.qml"
        }
        ListElement {
            name: "password"
            componentFile: "Components/Settings/SettingsPassword.qml"
        }
    }
}
