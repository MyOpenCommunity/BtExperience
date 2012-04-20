import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    height: buttonOnOff.height + controlVolume.height
    width: 212

    VolumeGeneral {
        id: controlVolume
        width: parent.width
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        onMinusClicked: column.dataModel.volumeDown()
        onPlusClicked: column.dataModel.volumeUp()
    }

    ButtonOnOff {
        id: buttonOnOff
        anchors.bottom: parent.bottom
        status: -1
        width: parent.width
        onClicked: column.dataModel.active = newStatus
    }
}
