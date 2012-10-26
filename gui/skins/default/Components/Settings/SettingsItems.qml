import QtQuick 1.1
import Components 1.0
import Components.Settings 1.0


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    // redefined to implement menu navigation
    function openMenu(navigationTarget) {
        if (navigationTarget === "Systems") {
            var m = modelList.get(7)
            itemList.currentIndex = 7
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
                if (model.name !== "") {
                    column.loadColumn(nameToComponent(model.component), model.name)
                }
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Home"), "component": "SettingsHome.qml"})
            modelList.append({"name": qsTr("General"), "component": "SettingsGenerals.qml"})
            modelList.append({"name": qsTr("Profiles"), "component": "SettingsProfiles.qml"})
            modelList.append({"name": qsTr("Rooms"), "component": "Floor.qml"})
            modelList.append({"name": qsTr("Systems"), "component": "SettingsSystems.qml"})
            modelList.append({"name": qsTr("Alarm Clock"), "component": "SettingsClocks.qml"})
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
