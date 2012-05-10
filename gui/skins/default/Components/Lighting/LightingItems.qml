import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: objectModel.size > elementsOnPage ? elementsOnPage * 50 : objectModel.size * 50

        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)

            status: itemObject.active === true ? 1 : 0
            hasChild: true
            onClicked: {
                column.loadColumn(
                            mapping.getComponent(itemObject.objectId),
                            itemObject.name,
                            objectModel.getObject(model.index))
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: objectModel
        categories: [ObjectInterface.Lighting]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
