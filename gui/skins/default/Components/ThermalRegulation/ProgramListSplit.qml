import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    signal programSelected(variant program)

    onChildDestroyed: paginator.currentIndex = -1

    ObjectModel {
        id: listModel
        source: dataModel.programs
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: listModel.getObject(index)
            name: itemObject.name
            onClicked: {
                column.programSelected(itemObject)
                column.closeColumn()
            }
        }
        model: listModel
    }
}
