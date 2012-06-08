import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    signal sourceSelected(variant object)

    PaginatorList {
        id: paginator
        listHeight: sourceModel.count * 50
        elementsOnPage: 8
        model: sourceModel
        delegate: MenuItem {
            id: sourceDelegate
            property variant itemObject: sourceModel.getObject(index)
            name: itemObject.name
            onClicked: column.sourceSelected(itemObject)
        }
    }

    ObjectModel {
        id: sourceModel
        filters: [{objectId: ObjectInterface.IdSoundSource}]
    }
}
