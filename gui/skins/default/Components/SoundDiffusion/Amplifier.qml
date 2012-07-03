import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    ControlOnOff {
        id: buttonOnOff
        status: column.dataModel.active
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
