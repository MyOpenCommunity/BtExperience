import QtQuick 1.1
import BtObjects 1.0

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
            itemObject: modelList.getObject(index)

            active: element.animationRunning === false
            status: itemObject.status === true ? 1 : 0
            hasChild: true
            onClicked: {
                element.loadElement(modelList.getComponentFile(itemObject.objectId), itemObject.name,
                                    modelList.getObject(model.index))
            }
        }

        model: modelList
    }

    ObjectModel {
        id: modelList
        categories: [ObjectInterface.Lighting]
    }
}

