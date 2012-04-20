import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
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
                    column.loadElement(model.componentFile, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "Piano terra"
            componentFile: "Components/Settings/RoomsItems.qml"
        }
        ListElement {
            name: "Primo piano"
            componentFile: "Components/Settings/RoomsItems.qml"
        }
    }
}
