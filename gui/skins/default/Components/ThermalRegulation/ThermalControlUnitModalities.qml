import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    property variant idx: -1

    signal modalitySelected(variant obj)

    ObjectModel {
        id: modalitiesModel
        source: column.dataModel.modalities
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        elementsOnPage: elementsOnMenuPage
        currentIndex: {
            for (var i = 0; i < model.count; ++i) {
                if (model.getObject(i) === column.idx)
                    return i
            }
            return -1
        }

        delegate: MenuItemDelegate {
            itemObject: modalitiesModel.getObject(index)
            onDelegateTouched: {
                column.modalitySelected(itemObject)
                column.closeColumn()
            }
        }
        model: modalitiesModel
    }
}
