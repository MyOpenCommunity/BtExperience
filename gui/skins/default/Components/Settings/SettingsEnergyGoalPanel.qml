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
import BtObjects 1.0

MenuColumn {
    id: column
    property int monthIndex: -1

    QtObject {
        id: privateProps
        property real goal: dataModel.goals[monthIndex]
    }

    Column {
        ControlMinusPlus {
            slowClickInterval: 200
            fastClickInterval: 60
            onPlusClicked: {
                if (dataModel.energyType === EnergyData.Electricity)
                    privateProps.goal += .1
                else
                    privateProps.goal += 1
            }

            onMinusClicked: {
                if (privateProps.goal > 0) {
                    if (dataModel.energyType === EnergyData.Electricity)
                        privateProps.goal -= .1
                    else
                        privateProps.goal -= 1
                }
            }

            text: privateProps.goal.toFixed(dataModel.decimals) + " " + dataModel.cumulativeUnit
            title: qsTr("consumption goal")
        }
        ButtonOkCancel {
            onOkClicked: {
                var goals = dataModel.goals
                goals[monthIndex] = privateProps.goal
                dataModel.goals = goals // because the EnergyData::setGoals has a list as argument we need this trick.
                column.closeColumn()
            }
            onCancelClicked: column.closeColumn()
        }
    }
}
