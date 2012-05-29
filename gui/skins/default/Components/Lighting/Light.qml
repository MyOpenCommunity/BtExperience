import QtQuick 1.1
import Components 1.0

MenuColumn {
    width: 212
    height: 39

    ControlOnOff {
        id: onOff
        width: parent.width
        status: dataModel.active
        onClicked: dataModel.active = newStatus
    }
}

