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
            onCancelClicked: column.dataModel.reset()
            onOkClicked: pageObject.installPopup(okCancelDialog)
        }
    }

    Component {
        id: okCancelDialog

        TextDialog {
            title: qsTr("Confirm operation")
            text: qsTr("Pressing ok will cause a device reboot in a few moments.\nPlease, do not use the touch till it is restarted.\nContinue?")

            function okClicked() {
                column.dataModel.apply()
            }
        }
    }
}
