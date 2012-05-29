import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: objectModel.count * 50
        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)
            description: objectModel.getObject(index).temperature / 10 + "°C"
            hasChild: true
            onClicked: {
                column.loadColumn(
                            mapping.getComponent(itemObject.objectId),
                            itemObject.name,
                            objectModel.getObject(model.index))
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario}
        ]
    }
}
