import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    Column {
        id: column

        ControlOnOff {
            status: dataModel.objectId === ObjectInterface.IdLightFixedPP ||
                    dataModel.objectId === ObjectInterface.IdLightCustomPP ?
                        dataModel.active : -1
            onClicked: dataModel.active = newStatus
        }

        ControlTiming {
            id: timing
            itemObject: dataModel
        }
    }
}
