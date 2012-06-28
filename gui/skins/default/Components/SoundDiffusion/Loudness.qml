import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    ControlOnOff {
        status: column.dataModel.loud
        onClicked: column.dataModel.loud = newStatus
    }
}
