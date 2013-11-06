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
import Components.Settings 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    // needed for menu navigation
    function targetsKnown() {
        return {
            "AlarmClock": privateProps.openAlarmClockMenu,
            "Profiles": privateProps.openProfilesMenu,
            "Systems": privateProps.openSystemsMenu,
            "Rooms": privateProps.openRoomsMenu,
            "General": privateProps.openGeneralMenu,
        }
    }

    Component { id: settingsHome; SettingsHome {} }
    Component { id: settingsGenerals; SettingsGenerals {} }
    Component { id: settingsProfiles; SettingsProfiles {} }
    Component { id: floor; Floor {} }
    Component { id: settingsSystems; SettingsSystems {} }
    Component { id: settingsClocks; SettingsClocks {} }
    Component { id: settingsMultimedia; SettingsMultimedia {} }
    Component { id: settingsRingtones; SettingsRingtones {} }

    QtObject {
        id: privateProps

        function openAlarmClockMenu(navigationData) {
            _openMenu(qsTr("Alarm Clock"))
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }

        function openProfilesMenu(navigationData) {
            _openMenu(qsTr("Profiles"))
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openSystemsMenu(navigationData) {
            _openMenu(qsTr("Functions"))
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openRoomsMenu(navigationData) {
            _openMenu(qsTr("Rooms"))
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openGeneralMenu(navigationData) {
            _openMenu(qsTr("General"))
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
            hasChild: true
            onDelegateTouched: column.loadColumn(model.component, model.name)
        }

        model: modelList
    }

    ObjectModel {
        id: profilesModel
        source: myHomeModels.profiles
    }

    MediaModel {
        id: floorsModel
        source: myHomeModels.floors
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
            modelList.append({name: qsTr("Home"), component: settingsHome})
            modelList.append({name: qsTr("General"), component: settingsGenerals})
            if (profilesModel.count > 0)
                modelList.append({name: qsTr("Profiles"), component: settingsProfiles})
            if (floorsModel.count > 0)
                modelList.append({name: qsTr("Rooms"), component: floor})
            if (scenariosModule.count + cctvModel.count + energyTariffs.count + energyGoals.count + energyThresholds.count > 0)
                modelList.append({name: qsTr("Functions"), component: settingsSystems})
            modelList.append({name: qsTr("Alarm Clock"), component: settingsClocks})
            modelList.append({name: qsTr("Multimedia"), component: settingsMultimedia})
            modelList.append({name: qsTr("Ringtones"), component: settingsRingtones})
        }
    }
}
