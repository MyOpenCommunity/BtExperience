import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    onChildDestroyed: itemList.currentIndex = -1

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            active: element.animationRunning === false
            hasChild: true
            onClicked: {
                element.loadElement(modelList.getComponentFile(model.objectId), model.name,
                                    modelList.getObject(model.index))
            }
        }

        model: modelList

        ObjectModel {
            id: modelList
            filters: [{objectId: ObjectInterface.IdThermalControlUnit99},
                      {objectId: ObjectInterface.IdThermalControlledProbe}]
        }
    }
}

