import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.ThermalRegulation 1.0
import "../../js/logging.js" as Log
import "../../js/EventManager.js" as EventManager


MenuColumn {
    id: column

    Column {
        DateSelect {
            dateText: qsTr("Date")
            timeText: qsTr("Time")
            dataModel: column.dataModel
        }
        ButtonOkCancel {
            onCancelClicked: column.closeColumn()
            onOkClicked: pageObject.installPopup(okCancelDialog)
        }
    }

    Component {
        id: okCancelDialog

        TextDialog {
            title: qsTr("Confirm operation")
            text: pageObject.names.get('REBOOT', 0)

            function okClicked() {
                column.dataModel.apply()
                EventManager.eventManager.notificationsEnabled = false
                Stack.backToHome({state: "pageLoading"})
            }
        }
    }
}
