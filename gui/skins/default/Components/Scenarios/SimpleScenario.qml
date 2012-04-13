import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: 50
    MenuItem {
        name: qsTr("activate")
        onClicked: {
            element.dataModel.activate()
            element.closeElement();
        }
    }
}
