import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: itemList.height + paginator.height * paginator.visible
    width: 212

    property int maxHeight: 300

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        height: 50 * count
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

    property int elementsOnPage: maxHeight / 50

    ObjectModel {
        id: modelList
        categories: [ObjectInterface.Lighting]//, ObjectInterface.ThermalRegulation]
        range: [0, elementsOnPage]
    }

    Paginator {
        id: paginator
        anchors.top: itemList.bottom
        pages: modelList.size % elementsOnPage ?
                   modelList.size / elementsOnPage + 1 : modelList.size / elementsOnPage

        onPageChanged: {
            modelList.range = [(page - 1) * elementsOnPage, page * elementsOnPage]
        }
    }
}

