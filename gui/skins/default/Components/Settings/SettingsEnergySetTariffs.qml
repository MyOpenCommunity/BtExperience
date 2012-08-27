import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    Column {
        ControlMinusPlus {
            id: temp
            title: qsTr("value ") + column.dataModel.name
            text:  "0,24 €/w"
        }

        ButtonOkCancel {
            onOkClicked: {
                column.closeColumn()
            }
            onCancelClicked: {
                column.closeColumn()
            }
        }
        }
}

