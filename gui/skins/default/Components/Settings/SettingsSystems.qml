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
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    // needed for menu navigation
    function targetsKnown() {
        return {
            "VDE": privateProps.openVDEMenu,
            "Scenarios": privateProps.openScenariosMenu,
            "Energy": privateProps.openEnergyMenu
        }
    }

    QtObject {
        id: privateProps

        function openVDEMenu(navigationData) {
            _openMenu(qsTr("Video Door Entry"))
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openScenariosMenu(navigationData) {
            _openMenu(qsTr("Scenarios"))
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openEnergyMenu(navigationData) {
            _openMenu(qsTr("Energy"))
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function _openMenu(name) {
            for (var i = 0; i < modelList.count; ++i) {
                var m = modelList.get(i)
                if (name === m.name) {
                    itemList.currentIndex = i
                    column.loadColumn(m.component, m.name)
                    return
                }
            }
        }
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: model.component !== undefined
                      && model.component !== null
            onDelegateTouched: {
                if (model.name !== "")
                    column.loadColumn(model.component, model.name)
            }
        }

        model: modelList
    }

    ObjectModel {
        id: scenariosModule
        filters: [
            {objectId: ObjectInterface.IdAdvancedScenario},
            {objectId: ObjectInterface.IdScenarioModule}
        ]
    }

    ObjectModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    ObjectModel {
        id: energyTariffs
        filters: [{objectId: ObjectInterface.IdEnergyRate}]
    }

    ObjectModel {
        id: energyGoals
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
    }

    ObjectModel {
        id: energyThresholds
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: EnergyData.Electricity}]
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            if (scenariosModule.count > 0)
                modelList.append({"name": qsTr("Scenarios"), "component": settingsScenario})
            if (energyTariffs.count + energyGoals.count + energyThresholds.count > 0)
                modelList.append({"name": qsTr("Energy"), "component": settingsEnergy})
            if (cctvModel.count > 0)
                modelList.append({"name": qsTr("Video Door Entry"), "component": settingsVDE})
        }
    }

    Component {
        id: settingsScenario
        SettingsScenarios {}
    }

    Component {
        id: settingsEnergy
        SettingsEnergy {}
    }

    Component {
        id: settingsVDE
        SettingsVDE {}
    }
}
