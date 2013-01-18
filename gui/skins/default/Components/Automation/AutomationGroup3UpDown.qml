import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlUpDownStop {
        onPressed: column.dataModel.setActive(newStatus)
    }
}
