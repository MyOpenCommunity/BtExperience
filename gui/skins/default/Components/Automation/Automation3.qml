import QtQuick 1.1
import Components 1.0


MenuColumn {
    Column {
        id: column

        ControlOpenCloseStop {
            status: dataModel.status
            onClicked: dataModel.status = newStatus
        }
    }
}
