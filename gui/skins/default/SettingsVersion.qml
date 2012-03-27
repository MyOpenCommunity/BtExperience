import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log


MenuElement {
    id: element

    // dimensions
    width: 212
    height: paginator.height

    // object model to retrieve version data
    ObjectModel {
        id: objectModel
        // TODO update filter to retrieve version data
        filters: [{objectId: ObjectInterface.IdNetwork}]
    }

    // TODO investigate why dataModel is not working as expected
    //dataModel: objectModel.getObject(0)
    QtObject {
        id: privateProps
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
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
        Column {
            // version item: it is a static list of values retrieved from app
            AnimatedLoader {
                id: versionLoader
            }
        }
    }

    // TODO: use the right background
    Component {
        id: versionItem
        Image {
            width: 212
            height: 50 * 3
            source: "images/common/bg_zone.png"
            anchors.bottom: parent.bottom
            Column {
                spacing: 5
                ControlTitleValue {
                    title: qsTr("firmware")
                    // TODO use the model value
                    //value: privateProps.model.firmware
                    value: "f.00000.1"
                }
                ControlTitleValue {
                    title: qsTr("software")
                    // TODO use the model value
                    //value: privateProps.model.software
                    value: "v.00000.1"
                }
                ControlTitleValue {
                    title: qsTr("serial number")
                    // TODO use the model value
                    //value: privateProps.model.serialNumber
                    value: "A0000000000"
                }
            }
        }
    }
}
