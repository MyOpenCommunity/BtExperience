import QtQuick 1.1
import Components 1.0

MenuElement {
    id: element
    height: buttonOnOff.height + controlVolume.height
    width: 212

    ButtonOnOff {
        id: buttonOnOff
        status: -1
        width: parent.width
        onClicked: element.dataModel.active = newStatus
    }

    ButtonMinusPlus {
        id: controlVolume
        width: parent.width
        anchors.top: buttonOnOff.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onMinusClicked: element.dataModel.volumeDown()
        onPlusClicked: element.dataModel.volumeUp()
    }
}
