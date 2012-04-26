import QtQuick 1.1
import Components 1.0
import Components.Settings 1.0


MenuColumn {
    id: column
    height: Math.max(1, 50 * itemList.count)
    width: 212

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
            hasChild: model.componentFile !== ""

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
            modelList.append({"name": qsTr("General"), "component": settingsGenerals})
            modelList.append({"name": qsTr("Profiles"), "component": profiles})
            modelList.append({"name": qsTr("Rooms"), "component": rooms})
            modelList.append({"name": qsTr("Alarm Clock"), "component": alarmClock})
            modelList.append({"name": qsTr("Notifications"), "component": notifications})
            modelList.append({"name": qsTr("Multimedia"), "component": multimedia})
        }
    }

    Component {
        id: settingsGenerals
        SettingsGenerals {}
    }

    Component {
        id: profiles
        Item {}
    }

    Component {
        id: rooms
        Floor {}
    }

    Component {
        id: alarmClock
        Item {}
    }

    Component {
        id: notifications
        Item {}
    }

    Component {
        id: multimedia
        Item {}
    }
}
