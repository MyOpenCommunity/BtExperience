import QtQuick 1.1

MenuElement {
    width: 245
    ButtonOnOff {
        status: false
        onClicked: status = newStatus
    }
}

