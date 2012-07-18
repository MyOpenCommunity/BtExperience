import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/Stack.js" as Stack

MenuColumn {
    id: element

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: energiesCounters.getObject(index)
            hasChild: true
            onClicked: Stack.openPage("EnergyDataDetail.qml", {"energyType": itemObject.energyType})
        }

        model: energiesCounters
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: "general"}]
    }
}
