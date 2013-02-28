import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    Component {
        id: sourceControl
        SourceControl {}
    }

    onChildDestroyed: privateProps.currentIndex = -1

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdAmplifierGeneral}]
    }

    Column {
        MenuItem {
            id: sourceLoader
            property variant itemObject: column.dataModel.currentSource
            isSelected: privateProps.currentIndex === 1
            name: qsTr("source")
            description: itemObject === undefined ? "" : itemObject.name
            hasChild: true
            onTouched: {
                privateProps.currentIndex = 1
                column.loadColumn(sourceControl, qsTr("source"), column.dataModel)
            }
        }

        Column {
            id: ambientControl
            property variant itemObject: objectModel.getObject(0)

            VolumeGeneral {
                onMinusClicked: ambientControl.itemObject.volumeDown()
                onPlusClicked: ambientControl.itemObject.volumeUp()
            }

            ControlOnOff {
                onClicked: ambientControl.itemObject.setActive(newStatus)
            }
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
