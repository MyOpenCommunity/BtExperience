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

import "../../js/Stack.js" as Stack

MenuColumn {
    id: element

    ObjectModel {
        id: energiesFamilies
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData}]
    }

    Column {
        PaginatorList {
            id: paginator

            elementsOnPage: elementsOnMenuPage - 1
            delegate: MenuItemDelegate {
                itemObject: energiesFamilies.getObject(index)
                hasChild: true
                // Energy data system is the only one that requires more than one page,
                // with properties set: this is a shortcut to avoid complicating
                // the code a lot.
                onDelegateTouched: {
                    resetSelection()
                    element.closeChild()
                    Stack.pushPage("EnergyDataDetail.qml", {"family": itemObject})
                }
            }

            model: energiesFamilies
            onCurrentPageChanged: column.closeChild()
        }

        MenuItem {
            name: qsTr("Global View")
            hasChild: true
            onTouched: Stack.goToPage("EnergyGlobalView.qml")

            enabled: {
                for (var i = 0; i < energiesCounters.count; i += 1) {
                    var energyData = energiesCounters.getObject(i)
                    if (!energyData.goalsEnabled)
                        continue

                    for (var j = 0; j < energyData.goals.length; j += 1)
                        if (energyData.goals[j] > 0)
                            return true
                }
                return false
            }
        }
    }


}
