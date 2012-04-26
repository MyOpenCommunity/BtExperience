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
            hasChild: model.component !== undefined
                      && model.component !== null

            onClicked: {
                if (model.name !== "")
                    column.loadColumn(model.component, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Add new room"), "component": addRoom})
            modelList.append({"name": qsTr("Kitchen"), "component": modifyRoom})
            modelList.append({"name": qsTr("Children Room"), "component": modifyRoom})
            modelList.append({"name": qsTr("Box"), "component": modifyRoom})
        }
    }

    Component {
        id: addRoom
        Item {}
    }

    Component {
        id: modifyRoom
        RoomModify {}
    }
}
