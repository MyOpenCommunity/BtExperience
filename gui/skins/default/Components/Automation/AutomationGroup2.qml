import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlOnOffGroup {
            onClicked: column.dataModel.setActive(newStatus)
    }
}
