import QtQuick 1.1
import bticino 1.0

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
                element.loadElement(lightingModel.getComponentFile(model.objectId), model.name,
                                    lightingModel.getObject(model.index))
            }
        }

        model: lightingModel
    }

    ObjectModel {
        id: lightingModel
        categories: [ObjectInterface.Lighting]
    }
}

