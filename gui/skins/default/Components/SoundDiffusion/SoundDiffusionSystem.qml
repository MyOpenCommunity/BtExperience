import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: itemList.height

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        height: 50 * count
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)
            status: itemObject.hasActiveAmplifier === undefined ? -1 : itemObject.hasActiveAmplifier
            hasChild: true
            onClicked:
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
        }

        model: objectModel
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMultiChannelGeneralAmbient},
            {objectId: ObjectInterface.IdMultiChannelSoundAmbient},
            {objectId: ObjectInterface.IdMonoChannelSoundAmbient},
        ]
    }
}
