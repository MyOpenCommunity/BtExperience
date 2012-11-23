import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdAdvancedScenario},
            {objectId: ObjectInterface.IdScenarioModule}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator

        currentIndex: -1
        model: objectModel
        onCurrentPageChanged: closeChild()

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
    }

    Component {
        id: scenario
        ScenarioModuleSettings {}
    }
}
