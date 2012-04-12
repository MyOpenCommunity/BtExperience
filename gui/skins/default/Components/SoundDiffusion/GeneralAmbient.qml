import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: element
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
            itemObject: element.dataModel.currentSource
            selected: privateProps.currentIndex === 1

            onItemClicked: {
                privateProps.currentIndex = 1
                element.loadElement("Components/SoundDiffusion/SourceControl.qml", qsTr("source"), element.dataModel)
            }

            Component.onCompleted: {
                console.log("currentSource: " + itemObject + ", dataModel: " + element.dataModel)
            }
        }

        VolumeGeneral {
            id: volume
            onPlusClicked: objectModel.getObject(0).volumeUp()
            onMinusClicked: objectModel.getObject(0).volumeDown()
        }

        ButtonOnOff {
            id: buttonOnOff
            width: element.width
            status: -1
            onClicked: objectModel.getObject(0).active = newStatus
        }
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: "0"}]
    }
}
