import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    Component.onCompleted: itemList.currentIndex = -1
    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        anchors.fill: parent
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)

            status: itemObject.active
            hasChild: true
            onClicked: element.loadElement(objectModel.getComponentFile(itemObject.objectId), itemObject.name, itemObject);
        }

        model: objectModel
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: element.dataModel.objectKey},
            {objectId: ObjectInterface.IdSoundAmplifier, objectKey: element.dataModel.objectKey},
            {objectId: ObjectInterface.IdPowerAmplifier, objectKey: element.dataModel.objectKey}]
    }
}
