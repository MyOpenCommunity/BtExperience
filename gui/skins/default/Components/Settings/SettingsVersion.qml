import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
    }

    ObjectModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)
    }

    Column {
        ControlTitleValue {
            title: qsTr("Firmware version")
            value: privateProps.model.firmwareVersion || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Kernel version")
            value: privateProps.model.kernelVersion || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Internal unit address")
            visible: vctModel.count > 0
            value: global.getPIAddress().slice(1) || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("External unit associated")
            visible: vctModel.count > 0
            value: global.defaultExternalPlace.where.slice(1) || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Multimedia source address")
            visible: global.multimediaSourceAddress !== ""
            value: global.multimediaSourceAddress
        }
    }
}
