import QtQuick 1.1
import Components 1.0

MenuColumn {
    Column {
        id: column

        ControlOnOff {
            active: dataModel.active
            onClicked: (timing.isEnabled && newStatus === true) ? dataModel.setActiveWithTiming() : dataModel.active = newStatus
        }

        ControlSlider {
            description: qsTr("light intensity")
            percentage: dataModel.percentage
            onPlusClicked: dataModel.increaseLevel()
            onMinusClicked: dataModel.decreaseLevel()
        }

        ControlTiming {
            id: timing
            itemObject: dataModel
        }
    }
}
