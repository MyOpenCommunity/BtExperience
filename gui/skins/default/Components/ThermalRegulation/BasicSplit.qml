import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: 50

    MenuItem {
        name: qsTr("Enable")
        description: ""
        state: element.dataModel.enable ? "selected" : ""
        onClicked: {
            element.dataModel.enable = true
            element.closeElement()
        }
    }
}
