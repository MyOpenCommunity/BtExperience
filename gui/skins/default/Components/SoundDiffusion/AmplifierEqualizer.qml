import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: 50 * paginator.elementsOnPage
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            name: itemObject.name
            selectOnClick: true
            onDelegateClicked: {
                column.dataModel.preset = index + objectModel.range[0]
            }
        }

        model: objectModel
    }

    ObjectModel {
        id: objectModel
        source: column.dataModel.presets
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
