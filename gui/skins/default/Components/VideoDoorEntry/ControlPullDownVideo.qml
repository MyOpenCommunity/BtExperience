import QtQuick 1.1
import Components 1.0


Item {
    id: control

    // we normally pass properties to the caller instead of objects inside other
    // objects to have reusable components but this control is very specific
    // to Video Door Entry system; in this case we prefer to pass the camera
    // object instead of passing 9 properties to the caller because they are really too many
    property variant camera

    ControlPullDown {
        menu: videoMenu
    }

    Component {
        id: videoMenu

        Column {
            ControlSlider {
                id: brightnessSlider
                percentage: control.camera === undefined ? 0 : control.camera.brightness
                description: qsTr("Brightness")
                onPlusClicked: if (control.camera !== undefined) control.camera.brightness += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.brightness -= 5
            }

            ControlSlider {
                id: contrastSlider
                percentage: control.camera === undefined ? 0 : control.camera.contrast
                description: qsTr("Contrast")
                onPlusClicked: if (control.camera !== undefined) control.camera.contrast += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.contrast -= 5
            }

            ControlSlider {
                id: colorSlider
                percentage: control.camera === undefined ? 0 : control.camera.color
                description: qsTr("Color")
                onPlusClicked: if (control.camera !== undefined) control.camera.color += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.color -= 5
            }
        }
    }
}
