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
import Components.Text 1.0


MenuColumn {
    id: element

    Column {

        ControlSwitch {
            text: qsTr("Auto close")
            pixelSize: 14
            onPressed: element.dataModel.autoReset = !element.dataModel.autoReset
            status: !element.dataModel.autoReset
            enabled: element.dataModel.status === StopAndGo.Closed
        }

        ControlSwitch {
            text: qsTr("Test Circuit Breaker")
            pixelSize: 14
            onPressed: element.dataModel.autoTest = !element.dataModel.autoTest
            status: !element.dataModel.autoTest
            visible: element.dataModel.status === StopAndGo.Closed
        }

        ControlMinusPlus {
            title: qsTr("Test every")
            text: element.dataModel.autoTestFrequency === -1 ? "---" : qsTr("%1 days").arg(element.dataModel.autoTestFrequency)
            changeable: element.dataModel.autoTestFrequency !== -1
            onMinusClicked: element.dataModel.decreaseAutoTestFrequency()
            onPlusClicked: element.dataModel.increaseAutoTestFrequency()
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ButtonOkCancel {
            id: confirmationButtons

            onOkClicked: {
                element.dataModel.apply()
                element.closeColumn()
            }
            onCancelClicked: {
                element.dataModel.reset()
                element.closeColumn()
            }
        }
    }
}
