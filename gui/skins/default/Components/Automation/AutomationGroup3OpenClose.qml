import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlOpenCloseStopGroup {
        onPressed: column.dataModel.setStatus(newStatus)
    }
}
