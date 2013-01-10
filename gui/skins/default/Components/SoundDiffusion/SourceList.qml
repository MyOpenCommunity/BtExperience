import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    signal sourceSelected(variant object)

    ObjectModel {
        id: sourceModel
        filters: [{objectId: ObjectInterface.IdSoundSource}]
    }

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        model: sourceModel
        delegate: MenuItem {
            id: sourceDelegate
            property variant itemObject: sourceModel.getObject(index)
            enabled: itemObject.mountPoint ? itemObject.mountPoint.mounted : true
            name: itemObject.name
            onClicked: column.sourceSelected(itemObject)
        }
        onCurrentPageChanged: column.closeChild()
    }
}
