import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack

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
                if (model.component === undefined) {
                    itemList.currentIndex = -1
                    column.closeChild()
                    Stack.pushPage(model.target)
                }
                else
                    column.loadColumn(model.component, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "Modify card image"
            target: "NewProfileCard.qml"
        }
        Component.onCompleted: {
            modelList.append({"name": qsTr("Modify background image")})
        }
    }
}
