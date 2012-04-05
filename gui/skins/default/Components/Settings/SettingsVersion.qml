import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0


MenuElement {
    id: element

    // dimensions
    width: 212
    height: paginator.height
    property string imagesPath: "../../images/"

    // object model to retrieve version data
    ObjectModel {
        id: objectModel
        // TODO update filter to retrieve version data
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)
    }

    // retrieves actual version information and sets the right component
    Component.onCompleted: {
        versionLoader.setComponent(versionItem)
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 150
        // version item: it is a static list of values retrieved from app
        AnimatedLoader {
            id: versionLoader
        }
    }

    // TODO: use the right background
    Component {
        id: versionItem
        Image {
            width: 212
            height: 50 * 3
            source: imagesPath + "common/bg_zone.png"
            anchors.bottom: parent.bottom
            Column {
                ControlTitleValue {
                    title: qsTr("firmware")
                    value: privateProps.model.firmware
                }
                ControlTitleValue {
                    title: qsTr("software")
                    value: privateProps.model.software
                }
                ControlTitleValue {
                    title: qsTr("serial number")
                    value: privateProps.model.serialNumber
                }
            }
        }
    }
}
