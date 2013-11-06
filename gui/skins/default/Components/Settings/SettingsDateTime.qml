/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
