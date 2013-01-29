import QtQuick 1.1
import Components 1.0


MenuColumn {
    ControlOnOff {
        status: dataModel.active
        onClicked: dataModel.active = newStatus
    }
}
