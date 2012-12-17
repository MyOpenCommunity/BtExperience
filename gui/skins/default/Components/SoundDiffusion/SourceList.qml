import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    signal sourceSelected(variant object)

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        model: sourceModel
        delegate: MenuItem {
            id: sourceDelegate
            property variant itemObject: sourceModel.getObject(index)
            name: itemObject.name
            onClicked: column.sourceSelected(itemObject)
        }
        onCurrentPageChanged: column.closeChild()
    }

    ObjectModel {
        id: sourceModel
        filters: [{objectId: ObjectInterface.IdSoundSource}]
    }
}
