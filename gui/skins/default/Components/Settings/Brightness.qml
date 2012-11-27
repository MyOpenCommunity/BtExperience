import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300

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

        ControlSlider {
            id: contrast
            percentage: global.guiSettings.contrast
            description: qsTr("contrast")
            onPlusClicked: {
                global.guiSettings.contrast += 5
                if (percentage > 100) global.guiSettings.contrast = 100
            }
            onMinusClicked: {
                global.guiSettings.contrast -= 5
                if (percentage < 0) global.guiSettings.contrast = 0
            }
        }
    }
}
