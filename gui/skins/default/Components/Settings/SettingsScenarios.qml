import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

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
            itemObject: objectModel.getObject(index)
            hasChild: true

            onClicked: {
                Stack.openPage("SettingsAdvancedScenario.qml",  {"scenarioObject": itemObject})
            }
        }

        model: objectModel
    }

    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdAdvancedScenario},
        ]
    }
}
