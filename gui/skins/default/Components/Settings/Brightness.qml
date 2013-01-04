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
        onPlusClicked: {
            if (percentage >= 95)
                global.screenState.normalBrightness = 100
            else
                global.screenState.normalBrightness += 5
        }
        onMinusClicked: {
            if (percentage <= 15)
                global.screenState.normalBrightness = 10
            else
                global.screenState.normalBrightness -= 5
        }
    }
}
