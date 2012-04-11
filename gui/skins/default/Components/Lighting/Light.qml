import QtQuick 1.1
import Components 1.0

MenuColumn {
    width: 212
    height: 50
    ButtonOnOff {
        status: dataModel.active
        onClicked: dataModel.active = newStatus
    }
}

