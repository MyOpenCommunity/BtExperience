import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    height: Math.max(1, 50 * itemList.count)
    width: 212

    // redefined to implement menu navigation
    function openMenu(navigationTarget) {
        if (navigationTarget === "VDE") {
            var m = modelList.get(2)
            itemList.currentIndex = 2
            column.loadColumn(m.component, m.name)
            return 1
        }
        return -2 // wrong target
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
