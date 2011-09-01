import QtQuick 1.1

MenuElement {
    width: 192
    ButtonOnOff {
        status: false
        onClicked: status = newStatus
    }
}

