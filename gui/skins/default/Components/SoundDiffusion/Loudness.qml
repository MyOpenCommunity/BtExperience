import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: 50
    ButtonOnOff {
        status: column.dataModel.loud
        onClicked: column.dataModel.loud = newStatus
    }
}
