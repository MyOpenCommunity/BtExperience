import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    QtObject {
        id: privateProps
        property int currentIndex: vctModel.getObject(0) === undefined ? -1 : (vctModel.getObject(0).ringExclusion ? 1 : 2)
        property variant model: vctModel.getObject(0)
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    Component.onCompleted: {
        // last menu to open, resets navigationTarget
        column.pageObject.navigationTarget = 0
    }

    Column {
        MenuItem {
            name: qsTr("enable")
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                if (privateProps.model)
                    privateProps.model.ringExclusion = true
            }
        }

        MenuItem {
            name: qsTr("disable")
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                if (privateProps.model)
                    privateProps.model.ringExclusion = false
            }
        }
    }
}

