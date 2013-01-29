import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlOnOff {
        onClicked: column.dataModel.setActive(newStatus)
    }
}
