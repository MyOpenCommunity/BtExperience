import QtQuick 1.1

MenuElement {
    width: 212
    height: 50
    ButtonOnOff {
        status: false
        onClicked: status = newStatus
    }
}

