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
        text: pageObject.names.get('HANDS_FREE', vctModel.getObject(0).handsFree)
        onClicked: vctModel.getObject(0).handsFree = !vctModel.getObject(0).handsFree
        status: !vctModel.getObject(0).handsFree
    }
}

