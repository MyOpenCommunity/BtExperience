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
        range: itemList.computePageRange(itemList.currentPage, itemList.elementsOnPage)
    }
}
