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
        }
    }

    QtObject {
        id: privateProps

        function openVDEMenu(navigationData) {
            var m = modelList.get(2)
            itemList.currentIndex = 2
            column.loadColumn(m.component, m.name)
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }

        function openScenariosMenu(navigationData) {
            var m = modelList.get(0)
            itemList.currentIndex = 0
            column.loadColumn(m.component, m.name)
            return NavigationConstants.NAVIGATION_IN_PROGRESS
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
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData}]
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            if (scenariosModule.count > 0)
                modelList.append({"name": qsTr("Scenarios"), "component": settingsScenario})
            if (energiesCounters.count > 0)
                modelList.append({"name": qsTr("Energy"), "component": settingsEnergy})
            if (cctvModel.count > 0)
                modelList.append({"name": qsTr("VDE"), "component": settingsVDE})
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
