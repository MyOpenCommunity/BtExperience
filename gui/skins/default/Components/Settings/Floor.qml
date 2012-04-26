import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    height: Math.max(1, 50 * itemList.count)
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
                column.loadColumn(model.comp, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Piano terra"), "comp": roomsItems})
            modelList.append({"name": qsTr("Primo piano"), "comp": roomsItems})
        }
    }

    Component {
        id: roomsItems
        RoomsItems {}
    }
}
