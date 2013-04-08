import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.ThermalRegulation 1.0
import "../../js/logging.js" as Log
import "../../js/EventManager.js" as EventManager
import "../../js/Stack.js" as Stack


/**
  * A menu to change system date and time.
  */
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
            property bool reboot

            title: qsTr("Confirm operation")
            text: pageObject.names.get('REBOOT', 0)

            onClosePopup: {
                if (reboot) {
                    EventManager.eventManager.notificationsEnabled = false
                    Stack.backToHome({state: "pageLoading"})
                }
            }

            function cancelClicked() {
                reboot = false
            }

            function okClicked() {
                column.dataModel.apply()
                reboot = true
            }
        }
    }
}
