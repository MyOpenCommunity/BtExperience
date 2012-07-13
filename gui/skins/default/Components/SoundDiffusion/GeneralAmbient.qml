import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    property string imagesPath: "../../images/"

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    Column {
        id: control

        MenuItem {
            id: sourceItem
            property variant itemObject: column.dataModel.currentSource
            isSelected: privateProps.currentIndex === 1
            name: qsTr("source")
            description: itemObject === undefined ? "" : itemObject.name
            hasChild: true
            onClicked: {
                privateProps.currentIndex = 1
                column.loadColumn(sourceControl, qsTr("source"), column.dataModel)
            }
        }

        VolumeGeneral {
            id: volume
            onPlusClicked: objectModel.getObject(0).volumeUp()
            onMinusClicked: objectModel.getObject(0).volumeDown()
        }

        ControlOnOff {
            id: buttonOnOff
            onClicked: objectModel.getObject(0).active = newStatus
        }
    }

    Component {
        id: sourceControl
        SourceControl {}
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: "0"}]
    }

    onChildDestroyed: privateProps.currentIndex = -1
}
