import QtQuick 1.1
import Components 1.0

MenuElement {
    id: element
    width: 212
    height: 50
    ButtonOnOff {
        status: element.dataModel.loud
        onClicked: element.dataModel.loud = newStatus
    }
}
