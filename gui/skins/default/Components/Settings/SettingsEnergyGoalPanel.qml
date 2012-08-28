import QtQuick 1.1
import Components 1.0


MenuColumn {
    id: column
    Column {
        ControlMinusPlus {
            text: "140 kwh"
            title: qsTr("consumption goal")
        }
        ButtonOkCancel {
            onOkClicked: column.closeColumn()
            onCancelClicked: column.closeColumn()
        }
    }
}
