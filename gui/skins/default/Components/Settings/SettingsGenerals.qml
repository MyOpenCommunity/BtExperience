import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    QtObject {
        id: privateProps

        function description(item) {
            if (item === qsTr("Password")) {
                if (global.passwordEnabled)
                    return qsTr("Enabled")
                else
                    return qsTr("Disabled")
            }

            if (item === qsTr("Beep")) {
                if (global.guiSettings.beep)
                    return qsTr("Enabled")
                else
                    return qsTr("Disabled")
            }

            return ""
        }
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            description: privateProps.description(model.name)
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
            modelList.append({"name": qsTr("Info"), "component": settingsVersion})
            modelList.append({"name": qsTr("Date & Time"), "component": settingsDateTime})
            modelList.append({"name": qsTr("Network"), "component": settingsNetwork})
            modelList.append({"name": qsTr("Display"), "component": settingsDisplay})
            modelList.append({"name": qsTr("International"), "component": settingsInternational})
            modelList.append({"name": qsTr("Password"), "component": settingsPassword})

            modelList.append({"name": qsTr("Beep"), "component": settingsBeep})
        }
    }

    Component {
        id: settingsVersion
        SettingsVersion {}
    }

    Component {
        id: settingsDateTime
        SettingsDateTime {}
    }

    Component {
        id: settingsNetwork
        SettingsNetwork {}
    }

    Component {
        id: settingsDisplay
        SettingsDisplay {}
    }

    Component {
        id: settingsInternational
        SettingsInternational {}
    }

    Component {
        id: settingsPassword
        SettingsPassword {}
    }

    Component {
        id: settingsBeep
        SettingsBeep {}
    }
}
