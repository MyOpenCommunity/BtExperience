import QtQuick 1.1
import Components 1.0
import BtObjects 1.0


MenuColumn {
    id: column

    PaginatorList {
        id: paginator
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
