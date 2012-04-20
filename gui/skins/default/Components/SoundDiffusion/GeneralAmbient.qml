import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212
    height: buttonOnOff.height + sourceItem.height + volume.height
    property string imagesPath: "../../images/"

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: column
        SoundSourceItem {
            id: sourceItem
            itemObject: column.dataModel.currentSource
            selected: privateProps.currentIndex === 1

            onItemClicked: {
                privateProps.currentIndex = 1
                column.loadElement("Components/SoundDiffusion/SourceControl.qml", qsTr("source"), column.dataModel)
            }

            Component.onCompleted: {
                console.log("currentSource: " + itemObject + ", dataModel: " + column.dataModel)
            }
        }

        VolumeGeneral {
            id: volume
            onPlusClicked: objectModel.getObject(0).volumeUp()
            onMinusClicked: objectModel.getObject(0).volumeDown()
        }

        ButtonOnOff {
            id: buttonOnOff
            width: column.width
            status: -1
            onClicked: objectModel.getObject(0).active = newStatus
        }
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: "0"}]
    }
}
