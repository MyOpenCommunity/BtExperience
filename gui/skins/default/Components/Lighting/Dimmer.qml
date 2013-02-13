import QtQuick 1.1
import Components 1.0

MenuColumn {
    Column {
        id: column

        ControlOnOff {
            status: dataModel.active
            onClicked: dataModel.active = newStatus
        }

        ControlSlider {
            description: qsTr("light intensity")
            percentage: dataModel.percentage
            sliderEnabled: dataModel.active
            onPlusClicked: dataModel.increaseLevel()
            onMinusClicked: dataModel.decreaseLevel()
            onSliderClicked: dataModel.percentage = desiredPercentage
        }

        ControlTiming {
            id: timing
            itemObject: dataModel
        }
    }
}
