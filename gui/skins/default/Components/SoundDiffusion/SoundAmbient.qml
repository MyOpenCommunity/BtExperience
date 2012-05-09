import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0

MenuColumn {
    id: column

    Component {
        id: sourceControl
        SourceControl {}
    }

    height: itemList.height + sourceLoader.height
    width: 212

    Component.onCompleted: itemList.currentIndex = -1
    onChildDestroyed: {
        itemList.currentIndex = -1
        privateProps.currentIndex = -1
    }

    SoundSourceItem {
        id: sourceLoader
        itemObject: column.dataModel.currentSource
        selected: privateProps.currentIndex === 1

        onItemClicked: {
            privateProps.currentIndex = 1
            itemList.currentIndex = -1
            column.loadColumn(
                        sourceControl,
                        qsTr("source"),
                        column.dataModel)
        }
    }

    ListView {
        id: itemList
        anchors.bottom: column.bottom
        height: 50 * itemList.count
        interactive: false

        delegate: MenuItemDelegate {
            editable: true
            itemObject: objectModel.getObject(index)

            status: itemObject.active
            hasChild: true
            onDelegateClicked: {
                privateProps.currentIndex = -1
                column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject);
            }
        }

        model: objectModel
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdSoundAmplifier, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdPowerAmplifier, objectKey: column.dataModel.objectKey}
        ]
    }
}
