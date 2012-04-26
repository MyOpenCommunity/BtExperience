import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height

    Column {
        id: column
        ControlUpDown {
            title: qsTr("self test")
            text: qsTr("enabled")
        }

        ControlMinusPlus {
            title: qsTr("self test interval")
            text: qsTr("30 days")
        }

        ButtonOkCancel {

        }
    }
}
