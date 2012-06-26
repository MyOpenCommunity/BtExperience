import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    width: 212
    height: itemList.height

    PaginatorList {
        id: itemList

        currentIndex: -1
        listHeight: Math.max(1, 50 * modelList.count)
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            hasChild: true
            onClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalExternalProbe}
        ]
    }
}
