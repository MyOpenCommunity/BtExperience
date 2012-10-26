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
            var m = modelList.get(4)
            itemList.currentIndex = 4
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
            modelList.append({"name": qsTr("Home"), "component": settingsHome})
            modelList.append({"name": qsTr("General"), "component": settingsGenerals})
            modelList.append({"name": qsTr("Profiles"), "component": profiles})
            modelList.append({"name": qsTr("Rooms"), "component": rooms})
            modelList.append({"name": qsTr("Systems"), "component": systems})
            modelList.append({"name": qsTr("Alarm Clock"), "component": alarmClock})
            modelList.append({"name": qsTr("Notifications"), "component": notifications})
//            modelList.append({"name": qsTr("Acoustic Signaling"), "component": boh})
            modelList.append({"name": qsTr("Multimedia"), "component": multimedia})
        }
    }

    Component {
        id: settingsHome
        SettingsHome {}
    }

    Component {
        id: settingsGenerals
        SettingsGenerals {}
    }

    Component {
        id: profiles
        SettingsProfiles {}
    }

    Component {
        id: rooms
        Floor {}
    }

    Component {
        id: alarmClock
        SettingsClocks {}
    }

    Component {
        id: notifications
        Item {}
    }

    Component {
        id: multimedia
        Item {}
    }

    Component {
        id: systems
        SettingsSystems {}
    }
}
