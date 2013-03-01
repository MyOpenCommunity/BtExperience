import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    ObjectModel {
        id: scenariosModule
        filters: [
            {objectId: ObjectInterface.IdAdvancedScenario},
            {objectId: ObjectInterface.IdScenarioModule}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    // needed for menu navigation
    function targetsKnown() {
        return {
            "Scenario": privateProps.openScenarioMenu,
        }
    }

    QtObject {
        id: privateProps

        function openScenarioMenu(navigationData) {
            var absIndex = scenariosModule.getAbsoluteIndexOf(navigationData)
            if (absIndex === -1)
                return NavigationConstants.NAVIGATION_SCENARIO_NOT_FOUND
            paginator.openDelegate(absIndex, paginator.openColumn)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
    }

    PaginatorList {
        id: paginator

        currentIndex: -1
        model: scenariosModule
        onCurrentPageChanged: column.closeChild()

        delegate: MenuItemDelegate {
            itemObject: scenariosModule.getObject(index)
            hasChild: true
            onDelegateTouched: openColumn(itemObject, resetSelection)
        }

        function openColumn(itemObject, resetCallback) {
            if (itemObject.objectId === ObjectInterface.IdAdvancedScenario) {
                resetCallback()
                itemObject.reset()
                Stack.pushPage("SettingsAdvancedScenario.qml",  {"scenarioObject": itemObject})
            }
            else
                loadColumn(scenario, itemObject.description, itemObject)
        }
    }

    Component {
        id: scenario
        ScenarioModuleSettings {}
    }
}
