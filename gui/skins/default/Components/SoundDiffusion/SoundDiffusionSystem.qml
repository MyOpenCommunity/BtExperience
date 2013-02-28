import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMultiChannelSpecialAmbient},
            {objectId: ObjectInterface.IdMultiChannelSoundAmbient},
            {objectId: ObjectInterface.IdMonoChannelSoundAmbient},
            {objectId: ObjectInterface.IdMultiGeneral},
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            status: Script.status(itemObject)
            hasChild: Script.hasChild(itemObject)
            // multi general ambient is not present in the layout file, so it
            // must not be editable
            editable: itemObject.objectId === ObjectInterface.IdMultiGeneral ? false : true
            onDelegateClicked: {
                if (itemObject.objectId !== ObjectInterface.IdMultiGeneral)
                    return
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
            }
            onDelegateTouched: {
                if (itemObject.objectId === ObjectInterface.IdMultiGeneral)
                    return
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
            }
        }

        model: objectModel
        onCurrentPageChanged: column.closeChild()
    }
}
