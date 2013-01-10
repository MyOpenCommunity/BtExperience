import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalNonControlledProbe}
        ]
    }

    PaginatorList {
        id: itemList

        currentIndex: -1
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            hasChild: true
            onClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }
}
