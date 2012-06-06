import QtQuick 1.1
import Components 1.0

MenuColumn {
    width: 212
    height: column.height

    Column {
        id: column

        width: parent.width

        ControlOnOff {
            id: onOff
            width: parent.width
            active: dataModel.active
            onClicked: (timing.isEnabled && newStatus === true) ? dataModel.setActiveWithTiming() : dataModel.active = newStatus
        }

        ControlSlider {
            width: parent.width
            description: qsTr("light intensity")
            percentage: dataModel.percentage
            onPlusClicked: dataModel.increaseLevel()
            onMinusClicked: dataModel.decreaseLevel()
        }

        ControlTiming {
            id: timing
            width: parent.width
            itemObject: dataModel
        }
    }
}
