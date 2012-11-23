import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)
            status: Script.status(itemObject)
            hasChild: Script.hasChild(itemObject)
            onClicked:
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
        }

        model: objectModel
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMultiChannelSpecialAmbient},
            {objectId: ObjectInterface.IdMultiChannelSoundAmbient},
            {objectId: ObjectInterface.IdMonoChannelSoundAmbient},
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
