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
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        controlPanel.status = 0
    }

    Column {
        ControlSwitch {
            upperText: qsTr("threshold 1")
            text: qsTr("%1").arg(status === 0 ? qsTr("enabled") : qsTr("disabled"))
            status: dataModel.thresholdEnabled[0] === true ? 0 : 1
            onPressed: dataModel.thresholdEnabled = [!dataModel.thresholdEnabled[0], dataModel.thresholdEnabled[1]]
        }

        ControlSwitch {
            upperText: qsTr("threshold 2")
            text: qsTr("%1").arg(status === 0 ? qsTr("enabled") : qsTr("disabled"))
            status: dataModel.thresholdEnabled[1] === true ? 0 : 1
            onPressed: dataModel.thresholdEnabled = [dataModel.thresholdEnabled[0], !dataModel.thresholdEnabled[1]]
        }

        ControlSettings {
            id: controlPanel
            upperLabel: qsTr("threshold 1")
            upperText: dataModel.thresholds[0].toFixed(3) + " " + dataModel.currentUnit
            bottomLabel: qsTr("threshold 2")
            bottomText: dataModel.thresholds[1].toFixed(3) + " " + dataModel.currentUnit
            onEditClicked: {
                column.loadColumn(panelComponent, dataModel.name, dataModel)
                status = status === 0 ? 1 : 0
            }

            Component {
                id: panelComponent
                SettingsEnergySetThresholdsPanel {

                }
            }
        }
    }
}
