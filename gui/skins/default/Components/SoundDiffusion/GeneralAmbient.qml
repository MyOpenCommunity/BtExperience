import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    Component {
        id: sourceControl
        SourceControl {}
    }

    width: 212
    height: buttonOnOff.height + sourceItem.height + volume.height
    property string imagesPath: "../../images/"

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: control
        SoundSourceItem {
            id: sourceItem
            itemObject: control.dataModel.currentSource
            selected: privateProps.currentIndex === 1

            onItemClicked: {
                privateProps.currentIndex = 1
                column.loadColumn(sourceControl, qsTr("source"), control.dataModel)
            }

            Component.onCompleted: {
                console.log("currentSource: " + itemObject + ", dataModel: " + control.dataModel)
            }
        }

        VolumeGeneral {
            id: volume
            onPlusClicked: objectModel.getObject(0).volumeUp()
            onMinusClicked: objectModel.getObject(0).volumeDown()
        }

        ButtonOnOff {
            id: buttonOnOff
            width: control.width
            status: -1
            onClicked: objectModel.getObject(0).active = newStatus
        }
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: "0"}]
    }
}
