import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    ControlSlider {
        percentage: global.screenState.contrast
        description: qsTr("Contrast")
        onPlusClicked: global.screenState.contrast += 5
        onMinusClicked: global.screenState.contrast -= 5
    }
}
