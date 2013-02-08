import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    ControlSwitch {
        text: pageObject.names.get('AUTO_OPEN', vctModel.getObject(0).autoOpen)
        onClicked: vctModel.getObject(0).autoOpen = !vctModel.getObject(0).autoOpen
        status: !vctModel.getObject(0).autoOpen
    }
}

