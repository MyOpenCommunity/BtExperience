import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: paginator.height

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        width: parent.width
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)

            active: element.animationRunning === false
            status: itemObject.status === true ? 1 : 0
            hasChild: true
            onClicked: {
                element.loadElement(objectModel.getComponentFile(itemObject.objectId), itemObject.name,
                                    objectModel.getObject(model.index))
            }
        }
        model: objectModel
    }

    ObjectModel {
        id: objectModel
        categories: [ObjectInterface.Lighting]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
