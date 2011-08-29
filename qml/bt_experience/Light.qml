import QtQuick 1.0

Item {
    ButtonOnOff {
        status: false
        onClicked: status = newStatus
    }
}

