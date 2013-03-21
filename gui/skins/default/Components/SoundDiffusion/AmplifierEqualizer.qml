import QtQuick 1.1
import Components 1.0
import BtObjects 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        source: column.dataModel.presets
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            name: itemObject.name
            selectOnClick: true
            onDelegateTouched: {
                column.dataModel.preset = index + objectModel.range[0]
                column.closeColumn()
            }
        }

        model: objectModel
        onCurrentPageChanged: column.closeChild()
    }
}
