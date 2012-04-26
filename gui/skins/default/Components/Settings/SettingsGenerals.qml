import QtQuick 1.1
import Components 1.0

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
                    column.loadColumn(model.comp, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Version"), "comp": settingsVersion})
            modelList.append({"name": qsTr("Date & Time"), "comp": settingsDateTime})
            modelList.append({"name": qsTr("Network"), "comp": settingsNetwork})
            modelList.append({"name": qsTr("Display"), "comp": settingsDisplay})
            modelList.append({"name": qsTr("International"), "comp": settingsInternational})
            modelList.append({"name": qsTr("Password"), "comp": settingsPassword})
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
}
