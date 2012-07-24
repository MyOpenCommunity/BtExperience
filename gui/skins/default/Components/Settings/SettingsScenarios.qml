import QtQuick 1.1
import Components 1.0
import "../../js/Stack.js" as Stack

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
            hasChild: true

            onClicked: {
                Stack.openPage("SettingsAdvancedScenario.qml")
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Advanced Scenario 1")})
            modelList.append({"name": qsTr("Advanced Scenario 2")})
        }
    }
}
