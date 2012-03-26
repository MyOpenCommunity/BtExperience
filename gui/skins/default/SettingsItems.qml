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
            name: "generals"
            componentFile: "SettingsGenerals.qml"
        }
        ListElement {
            name: "profiles"
            componentFile:""
        }
        ListElement {
            name: "rooms"
            componentFile:"Floor.qml"
        }
        ListElement {
            name: "alarm clock"
            componentFile:""
        }
        ListElement {
            name: "notifications"
            componentFile:""
        }
        ListElement {
            name: "multimedia"
            componentFile:""
        }
    }
}
