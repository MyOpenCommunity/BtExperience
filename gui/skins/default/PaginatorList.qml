import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: itemList.height + paginator.height * paginator.visible
    width: 212

    property int maxHeight: 300
    // cannot export categories only, otherwise menus that use this component
    // will have one page more. I don't understand why.
    property alias paginatorModel: modelList

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

    QtObject {
        id: privateProps
        property int elementsOnPage: maxHeight / 50
    }


    ObjectModel {
        id: modelList
        categories: [ObjectInterface.Lighting]
        range: paginator.computePageRange(paginator.currentPage, privateProps.elementsOnPage)
    }

    Paginator {
        id: paginator
        anchors.top: itemList.bottom
        totalPages: paginator.computePagesFromModelSize(modelList.size, privateProps.elementsOnPage)
    }
}

