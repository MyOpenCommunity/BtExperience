import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/Stack.js" as Stack

MenuColumn {
    id: element

    ObjectModel {
        id: energiesFamilies
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData}]
    }

    Column {
        PaginatorList {
            id: paginator

            elementsOnPage: elementsOnMenuPage - 1
            delegate: MenuItemDelegate {
                itemObject: energiesFamilies.getObject(index)
                hasChild: true
                // Energy data system is the only one that requires more than one page,
                // with properties set: this is a shortcut to avoid complicating
                // the code a lot.
                onClicked: Stack.pushPage("EnergyDataDetail.qml", {"family": itemObject})
            }

            model: energiesFamilies
            onCurrentPageChanged: column.closeChild()
        }

        MenuItem {
            name: qsTr("Global View")
            hasChild: true
            onClicked: Stack.goToPage("EnergyGlobalView.qml")

            enabled: {
                for (var i = 0; i < energiesCounters.count; i += 1) {
                    var energyData = energiesCounters.getObject(i)
                    if (!energyData.goalsEnabled)
                        continue

                    for (var j = 0; j < energyData.goals.length; j += 1)
                        if (energyData.goals[j] > 0)
                            return true
                }
                return false
            }
        }
    }


}
