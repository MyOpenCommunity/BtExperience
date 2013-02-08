import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * itemList.count)

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    function targetsKnown() {
        return {
            "DateTime": privateProps.navigateDateTimeMenu,
        }
    }

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
    }

    QtObject {
        id: privateProps

        function description(item) {
            if (item === "Password") {
                if (global.passwordEnabled)
                    return qsTr("Enabled")
                else
                    return qsTr("Disabled")
            }

            if (item === "Beep") {
                if (global.guiSettings.beep)
                    return qsTr("Enabled")
                else
                    return qsTr("Disabled")
            }

            if (item === "Network") {
                if (objectModel.getObject(0).connectionStatus === PlatformSettings.Down)
                    return qsTr("Disconnected")
                else
                    return qsTr("Connected")
            }

            return ""
        }

        function openDateTimeMenu() {
            var o = objectModel.getObject(0)
            o.reset() // to have current date & time
            column.loadColumn(settingsDateTime, qsTr("Date & Time"), o)
        }

        function navigateDateTimeMenu(navigationData) {
            for (var i = 0; i < modelList.count; ++i) {
                var m = modelList.get(i)
                if ("Date & Time" === m.name) {
                    itemList.currentIndex = i
                    break
                }
            }
            openDateTimeMenu()
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: qsTr(model.name)
            description: privateProps.description(model.name)
            hasChild: model.component !== undefined
                      && model.component !== null

            onClicked: {
                if (model.name !== "Date & Time")
                    column.loadColumn(model.component, qsTr(model.name))
                else {
                    privateProps.openDateTimeMenu()
                }
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList

        Component.onCompleted: {
            modelList.append({"name": QT_TR_NOOP("Info"), "component": settingsVersion})
            modelList.append({"name": QT_TR_NOOP("Date & Time"), "component": settingsDateTime})
            modelList.append({"name": QT_TR_NOOP("Network"), "component": settingsNetwork})
            modelList.append({"name": QT_TR_NOOP("Display"), "component": settingsDisplay})
            modelList.append({"name": QT_TR_NOOP("International"), "component": settingsInternational})
            modelList.append({"name": QT_TR_NOOP("Password"), "component": settingsPassword})
            modelList.append({"name": QT_TR_NOOP("Beep"), "component": settingsBeep})
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
