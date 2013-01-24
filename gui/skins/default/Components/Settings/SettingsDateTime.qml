import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.ThermalRegulation 1.0
import "../../js/logging.js" as Log


MenuColumn {
    id: column

    Column {
        DateSelect {
            dateText: qsTr("Date")
            timeText: qsTr("Time")
            dataModel: column.dataModel
        }
        ButtonOkCancel {
            onCancelClicked: dataModel.reset()
            onOkClicked: dataModel.apply()
        }
    }
}
