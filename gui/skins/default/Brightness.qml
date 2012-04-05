import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log


MenuElement {
    id: element

    width: 212
    height: paginator.height

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdHardwareSettings}]
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
        property variant model: objectModel.getObject(0)
    }

    onChildDestroyed: privateProps.currentIndex = -1

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300

        ControlSlider {
            id: brightness
            percentage: privateProps.model.brightness
            description: qsTr("brightness")
            onPlusClicked: {
                privateProps.model.brightness += 5
                if (percentage > 100) privateProps.model.brightness = 100
            }
            onMinusClicked: {
                privateProps.model.brightness -= 5
                if (percentage < 0) privateProps.model.brightness = 0
            }
        }

        ControlSlider {
            id: contrast
            percentage: privateProps.model.contrast
            description: qsTr("contrast")
            onPlusClicked: {
                privateProps.model.contrast += 5
                if (percentage > 100) privateProps.model.contrast = 100
            }
            onMinusClicked: {
                privateProps.model.contrast -= 5
                if (percentage < 0) privateProps.model.contrast = 0
            }
        }
    }
}
