import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    Column {
        MenuItem {
            name: qsTr("inbox")
        }

        MenuItem {
            name: qsTr("new message")
        }
    }
}
