import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            hasChild: true

            onClicked: {
                if (itemObject.objectId === ObjectInterface.IdAdvancedScenario) {
                    itemObject.reset()
                    Stack.pushPage("SettingsAdvancedScenario.qml",  {"scenarioObject": itemObject})
                }
                else
                    loadColumn(scenario, name, itemObject)
            }
        }

        model: objectModel

        onCurrentPageChanged: closeChild()
    }

    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdAdvancedScenario},
            {objectId: ObjectInterface.IdScenarioModule}
        ]
        range: itemList.computePageRange(itemList.currentPage, itemList.elementsOnPage)
    }

    Component {
        id: scenario
        ScenarioModuleSettings {}
    }
}
