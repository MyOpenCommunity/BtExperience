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
            name: "Aggiungi nuova stanza"
            componentFile: ""
        }

        ListElement {
            name: "Cucina"
            componentFile: "Components/Settings/RoomModify.qml"
        }
        ListElement {
            name: "Camera ragazzi"
            componentFile: "Components/Settings/RoomModify.qml"
        }
        ListElement {
            name: "box"
            componentFile: "Components/Settings/RoomModify.qml"
        }
    }
}
