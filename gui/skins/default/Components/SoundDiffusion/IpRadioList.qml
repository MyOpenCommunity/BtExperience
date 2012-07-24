import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        delegate: MenuItemDelegate {
            itemObject: radioModel.getObject(index)
            editable: true
            onDelegateClicked: {
                console.log("Clicked on element: " + itemObject)
                column.dataModel.startPlay(itemObject)
            }
        }

        model: radioModel
    }

    ObjectModel {
        id: radioModel
        filters: [{objectId: ObjectInterface.IdIpRadio}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
