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
            percentage: global.guiSettings.brightness
            description: qsTr("brightness")
            onPlusClicked: {
                if (percentage >= 100)
                    global.guiSettings.brightness = 100
                else
                    global.guiSettings.brightness += 5
            }
            onMinusClicked: {
                if (percentage <= 10)
                    global.guiSettings.brightness = 10
                else
                    global.guiSettings.brightness -= 5
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
