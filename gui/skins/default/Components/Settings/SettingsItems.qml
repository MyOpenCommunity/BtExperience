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
            _openMenu(qsTr("Systems"))
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
            onClicked: column.loadColumn(model.component, model.name)
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
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData}]
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
            if (scenariosModule.count + cctvModel.count + energiesCounters.count > 0)
                modelList.append({name: qsTr("Systems"), component: settingsSystems})
            modelList.append({name: qsTr("Alarm Clock"), component: settingsClocks})
            modelList.append({name: qsTr("Multimedia"), component: settingsMultimedia})
            modelList.append({name: qsTr("Ringtones"), component: settingsRingtones})
        }
    }
}
