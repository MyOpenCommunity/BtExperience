import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    ControlSlider {
        id: brightness
        percentage: global.screenState.normalBrightness
        description: qsTr("brightness")
        onPlusClicked: global.screenState.normalBrightness += 5
        onMinusClicked: global.screenState.normalBrightness -= 5
    }
}
