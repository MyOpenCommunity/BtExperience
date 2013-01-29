import QtQuick 1.1
import Components 1.0


MenuColumn {
    ControlUpDownStopSafe {
        status: dataModel.status
        onPressed: dataModel.status = newStatus
    }
}
