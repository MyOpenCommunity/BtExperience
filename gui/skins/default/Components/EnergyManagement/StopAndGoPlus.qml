import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height

    Column {
        id: column
        ControlUpDownReset {
            title: qsTr("automatic reset")
            text: qsTr("disabled")
        }

        ControlUpDown {
            title: qsTr("system check")
            text: qsTr("disabled")
        }

        ButtonOkCancel {

        }
    }
}
