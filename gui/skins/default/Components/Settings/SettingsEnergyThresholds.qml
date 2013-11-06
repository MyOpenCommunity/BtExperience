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

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: EnergyData.Electricity}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Column {
        ControlSwitch {
            text: qsTr("alerts %1").arg(global.guiSettings.energyThresholdBeep ? qsTr("enabled") : qsTr("disabled"))
            status: global.guiSettings.energyThresholdBeep ? 0 : 1
            onPressed: global.guiSettings.energyThresholdBeep = !global.guiSettings.energyThresholdBeep
        }

        PaginatorList {
            id: paginator
            delegate: MenuItemDelegate {
                itemObject: energiesCounters.getObject(index)
                hasChild: true
                onDelegateTouched: column.loadColumn(thresholdsComponent, itemObject.name, itemObject)
            }

            elementsOnPage: elementsOnMenuPage - 1
            onCurrentPageChanged: column.closeChild()
            model: energiesCounters
        }
    }

    Component {
        id: thresholdsComponent
        SettingsEnergySetThresholds {

        }
    }
}
