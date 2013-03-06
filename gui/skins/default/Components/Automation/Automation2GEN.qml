import QtQuick 1.1
import Components 1.0


MenuColumn {
    ControlOnOff {
        onClicked: dataModel.active = newStatus
    }
}
