import QtQuick 1.1

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
            componentFile:"SettingsVersion.qml"
        }
        ListElement {
            name: "date & time"
            componentFile:"SettingsDateTime.qml"
        }
        ListElement {
            name: "network"
            componentFile:"SettingsNetwork.qml"
        }
        ListElement {
            name: "display"
            componentFile: "SettingsDisplay.qml"
        }
        ListElement {
            name: "international"
            componentFile:"SettingsInternational.qml"
        }
        ListElement {
            name: "password"
            componentFile:"SettingsPassword.qml"
        }
    }
}
