import QtQuick 1.1
import Components 1.0


MenuColumn {
    ControlOnOff {
        status: -1
        onClicked: dataModel.active = newStatus
    }
}
