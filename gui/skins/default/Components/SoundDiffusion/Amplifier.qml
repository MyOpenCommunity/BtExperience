import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    height: buttonOnOff.height + volumeSlider.height
    width: 212

    onChildDestroyed: amplifierSettings.state = ""

    ButtonOnOff {
        id: buttonOnOff
        status: element.dataModel.active
        height: 50
        onClicked: element.dataModel.active = newStatus
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
        percentage: (element.dataModel.volume) * 100 / 31
        onMinusClicked: element.dataModel.volumeDown()
        onPlusClicked: element.dataModel.volumeUp()
    }
}
