import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    height: buttonOnOff.height + volumeSlider.height
    width: 212

    onChildDestroyed: amplifierSettings.state = ""

    ButtonOnOff {
        id: buttonOnOff
        width: column.width
        status: column.dataModel.active
        height: 50
        onClicked: column.dataModel.active = newStatus
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
        percentage: (column.dataModel.volume) * 100 / 31
        onMinusClicked: column.dataModel.volumeDown()
        onPlusClicked: column.dataModel.volumeUp()
    }
}
