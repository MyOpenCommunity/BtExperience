import QtQuick 1.0

MenuElement {
    width: 192
    ButtonOnOff {
        status: false
        onClicked: status = newStatus
    }
}

