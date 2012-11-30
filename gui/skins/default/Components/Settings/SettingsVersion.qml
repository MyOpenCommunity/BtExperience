import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        // TODO update filter to retrieve version data
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)
    }

    Column {
        ControlTitleValue {
            title: qsTr("firmware")
            value: privateProps.model.firmware || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("software")
            value: privateProps.model.software || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("serial number")
            value: privateProps.model.serialNumber || qsTr("Unknown")
        }
    }
}
