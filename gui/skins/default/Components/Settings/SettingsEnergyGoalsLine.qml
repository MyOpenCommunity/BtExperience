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
        privateProps.currentIndex = -1
    }

    Image {
        id: background
        source: "../../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    QtObject {
        id: privateProps
        function getMonthName(index) {
            switch (index) {
            case 0:
                return qsTr("January")
            case 1:
                return qsTr("February")
            case 2:
                return qsTr("March")
            case 3:
                return qsTr("April")
            case 4:
                return qsTr("May")
            case 5:
                return qsTr("June")
            case 6:
                return qsTr("July")
            case 7:
                return qsTr("August")
            case 8:
                return qsTr("September")
            case 9:
                return qsTr("October")
            case 10:
                return qsTr("November")
            case 11:
                return qsTr("December")
            }
        }
        property int currentIndex: -1
    }

    Column {
        ControlSwitch {
            text: qsTr("goals enabled")
            status: dataModel.goalsEnabled === true ? 0 : 1
            onPressed: dataModel.goalsEnabled = !dataModel.goalsEnabled
        }

        Component {
            id: panelComponent
            SettingsEnergyGoalPanel {
            }
        }

        PaginatorColumn {
            maxHeight: 300
            onCurrentPageChanged: column.closeChild()
            Repeater {
                MenuItem {
                    name: privateProps.getMonthName(index)
                    description: dataModel.goals[index].toFixed(dataModel.decimals) + " " + dataModel.cumulativeUnit
                    hasChild: true
                    isSelected: privateProps.currentIndex === index
                    onTouched: {
                        privateProps.currentIndex = index
                        column.loadColumn(panelComponent, privateProps.getMonthName(index), dataModel, {monthIndex: index})
                    }
                }
                model: 12
            }
        }
    }
}

