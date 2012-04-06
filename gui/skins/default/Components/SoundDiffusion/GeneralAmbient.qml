import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: buttonOnOff.height + sourceItem.height + volume.height
    property string imagesPath: "../../images/"

    Column {
        id: column
        MenuItem {
            id: sourceItem
            name: "source"
            hasChild: true
            description: "Radio | FM 108.7 - Radio Cassadritta"
            status: -1
            onClicked: element.loadElement("Components/SoundDiffusion/SourceControl.qml", qsTr("source"))
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
