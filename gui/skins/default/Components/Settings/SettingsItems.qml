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
        }
    }

    QtObject {
        id: privateProps

        function openAlarmClockMenu(navigationData) {
            _openMenu(5)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }

        function openProfilesMenu(navigationData) {
            _openMenu(2)
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openSystemsMenu(navigationData) {
            _openMenu(4)
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function _openMenu(index) {
            var m = modelList.get(index)
            itemList.currentIndex = index
            column.loadColumn(nameToComponent(m.component), m.name)
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

            onClicked: {
                if (model.name !== "") {
                    column.loadColumn(nameToComponent(model.component), model.name)
                }
            }
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
            modelList.append({"name": qsTr("Home"), "component": "SettingsHome.qml"})
            modelList.append({"name": qsTr("General"), "component": "SettingsGenerals.qml"})
            if (profilesModel.count > 0)
                modelList.append({"name": qsTr("Profiles"), "component": "SettingsProfiles.qml"})
            if (floorsModel.count > 0)
                modelList.append({"name": qsTr("Rooms"), "component": "Floor.qml"})
            if (scenariosModule.count + cctvModel.count + energiesCounters.count > 0)
                modelList.append({"name": qsTr("Systems"), "component": "SettingsSystems.qml"})
            modelList.append({"name": qsTr("Alarm Clock"), "component": "SettingsClocks.qml"})
            modelList.append({"name": qsTr("Multimedia"), "component": "SettingsMultimedia.qml"})
            modelList.append({"name": qsTr("Ringtones"), "component": "SettingsRingtones.qml"})
        }
    }

    function nameToComponent(name) {
        var component = Qt.createComponent(name)
        // TODO: handle more states
        if (component.status === Component.Ready) {
            return component
        }
        console.log("Error on creating component for settings:" + component.errorString())
    }
}
