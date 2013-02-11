import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/MediaItem.js" as Script

MenuColumn {
    id: column

    signal sourceSelected(variant object)

    SourceModel { id: sourceModel }

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        model: sourceModel.model
        delegate: MenuItem {
            id: sourceDelegate
            property variant itemObject: sourceModel.model.getObject(index)
            enabled: Script.mediaItemEnabled(itemObject)
            name: itemObject.name
            onClicked: column.sourceSelected(itemObject)
        }
        onCurrentPageChanged: column.closeChild()
    }
}
