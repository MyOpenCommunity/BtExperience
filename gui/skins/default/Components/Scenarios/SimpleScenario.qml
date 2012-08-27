import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    MenuItem {
        name: qsTr("activate")
        onClicked: {
            column.dataModel.activate()
            column.closeColumn();
        }
    }
}
