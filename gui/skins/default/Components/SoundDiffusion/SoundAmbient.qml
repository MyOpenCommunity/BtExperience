import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0

MenuColumn {
    id: element
    height: itemList.height + sourceLoader.height
    width: 212

    Component.onCompleted: itemList.currentIndex = -1
    onChildDestroyed: {
        itemList.currentIndex = -1
        privateProps.currentIndex = -1
    }

    SoundSourceItem {
        id: sourceLoader
        itemObject: element.dataModel.currentSource
        selected: privateProps.currentIndex === 1

        onItemClicked: {
            privateProps.currentIndex = 1
            itemList.currentIndex = -1
            element.loadElement("Components/SoundDiffusion/SourceControl.qml", qsTr("source"), element.dataModel)
        }
    }

    ListView {
        id: itemList
        anchors.bottom: element.bottom
        height: 50 * itemList.count
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)

            status: itemObject.active
            hasChild: true
            onDelegateClicked: {
                privateProps.currentIndex = -1
                element.loadElement(objectModel.getComponentFile(itemObject.objectId), itemObject.name, itemObject);
            }
        }

        model: objectModel
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: element.dataModel.objectKey},
            {objectId: ObjectInterface.IdSoundAmplifier, objectKey: element.dataModel.objectKey},
            {objectId: ObjectInterface.IdPowerAmplifier, objectKey: element.dataModel.objectKey}
        ]
    }
}
