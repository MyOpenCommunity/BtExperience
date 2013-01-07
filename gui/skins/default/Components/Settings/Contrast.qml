import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    ControlSlider {
        percentage: global.screenState.contrast
        description: qsTr("Contrast")
        onPlusClicked: {
            if (percentage >= 95)
                global.screenState.contrast = 100
            else
                global.screenState.contrast += 5
        }
        onMinusClicked: {
            if (percentage <= 15)
                global.screenState.contrast = 10
            else
                global.screenState.contrast -= 5
        }
    }
}
