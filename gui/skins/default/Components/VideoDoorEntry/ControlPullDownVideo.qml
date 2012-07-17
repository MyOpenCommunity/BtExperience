import QtQuick 1.1
import Components 1.0


Item {
    id: control

    property variant camera
    Component.onCompleted: console.log("camera: "+camera)

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
                id: saturationSlider
                percentage: control.camera === undefined ? 0 : control.camera.saturation
                description: qsTr("Saturation")
                onPlusClicked: if (control.camera !== undefined) control.camera.saturation += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.saturation -= 5
            }
        }
    }
}
