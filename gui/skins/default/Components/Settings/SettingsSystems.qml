import QtQuick 1.1
import Components 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    // redefined to implement menu navigation
    function openMenu(navigationTarget, navigationData) {
        if (navigationTarget === "VDE") {
            var m = modelList.get(2)
            itemList.currentIndex = 2
            column.loadColumn(m.component, m.name)
            return NavigationConstants.NAVIGATION_IN_PROGRESS
        }
        return NavigationConstants.NAVIGATION_WRONG_TARGET
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

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Scenarios"), "component": settingsScenario})
            modelList.append({"name": qsTr("Energy"), "component": settingsEnergy})
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
