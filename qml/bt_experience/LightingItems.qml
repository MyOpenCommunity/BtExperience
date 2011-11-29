import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }
    onChildAnimation: {
        itemList.transparent = running ? false : true
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false
        property bool transparent: true

        delegate: MenuItemDelegate {
            status: model.status === true ? 1 : 0
            hasChild: true
            onClicked: {
                element.loadElement(modelList.getComponentFile(model.objectId), model.name,
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

