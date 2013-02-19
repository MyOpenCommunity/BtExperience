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
        text: pageObject.names.get('RING_EXCLUSION', vctModel.getObject(0).ringExclusion)
        onPressed: vctModel.getObject(0).ringExclusion = !vctModel.getObject(0).ringExclusion
        status: !vctModel.getObject(0).ringExclusion
    }
}

