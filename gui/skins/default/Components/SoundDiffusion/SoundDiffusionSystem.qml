import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: system
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
            itemObject: objectModel.getObject(index)
            status: itemObject.hasActiveAmplifier === undefined ? -1 : itemObject.hasActiveAmplifier
            hasChild: true
            onClicked:
                system.loadElement(objectModel.getComponentFile(itemObject.objectId), itemObject.name, itemObject)
        }

        model: objectModel
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMultiChannelGeneralAmbient},
            {objectId: ObjectInterface.IdMultiChannelSoundAmbient}]
    }
}
