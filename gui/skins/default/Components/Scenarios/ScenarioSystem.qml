import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: Math.max(1, 50 * itemList.count)

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            hasChild: true
            onClicked:
                column.loadColumn(
                    mapping.getComponent(itemObject.objectId),
                    itemObject.name,
                    itemObject)
        }

        model: objectModel
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSimpleScenario},
            {objectId: ObjectInterface.IdScenarioModule},
        ]
    }
}
