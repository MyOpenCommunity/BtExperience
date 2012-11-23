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

    // the following is needed to call the getAbsoluteIndexOf function (if you set a range
    // you cannot get items outside the range)
    ObjectModel {
        id: unrangedScenariosModule
        filters: [
            {objectId: ObjectInterface.IdAdvancedScenario},
            {objectId: ObjectInterface.IdScenarioModule}
        ]
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    // needed for menu navigation
    function targetsKnown() {
        return {
            "Scenario": privateProps.openScenarioMenu,
        }
    }

    QtObject {
        id: privateProps

        function openScenarioMenu(navigationData) {
            var absIndex = unrangedScenariosModule.getAbsoluteIndexOf(navigationData)
            if (absIndex === -1)
                return NavigationConstants.NAVIGATION_SCENARIO_NOT_FOUND
            var indexes = paginator.getIndexesInPaginator(absIndex)
            paginator.openDelegate(indexes)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
    }

    PaginatorList {
        id: paginator

        currentIndex: -1
        model: scenariosModule
        onCurrentPageChanged: closeChild()

        delegate: MenuItemDelegate {
            itemObject: scenariosModule.getObject(index)
            hasChild: true

            onClicked: openDelegate([currentPage, index])
        }

        function openDelegate(indexes) {
            paginator.goToPage(indexes[0])
            currentIndex = indexes[1]
            var itemObject = scenariosModule.getObject(currentIndex)
            if (itemObject.objectId === ObjectInterface.IdAdvancedScenario) {
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
