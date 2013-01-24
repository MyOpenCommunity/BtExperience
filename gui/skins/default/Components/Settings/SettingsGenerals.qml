import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
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

            if (item === qsTr("Network")) {
                if (objectModel.getObject(0).connectionStatus === PlatformSettings.Down)
                    return qsTr("Disconnected")
                else
                    return qsTr("Connected")
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
                if (model.name !== qsTr("Date & Time"))
                    column.loadColumn(model.component, model.name)
                else {
                    var o = objectModel.getObject(0)
                    o.reset() // to have current date & time
                    column.loadColumn(model.component, model.name, o)
                }
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
