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
            // Energy data system is the only one that requires more than one page,
            // with properties set: this is a shortcut to avoid complicating
            // the code a lot.
            onClicked: Stack.pushPage("EnergyDataDetail.qml", {"family": itemObject})
        }

        model: energiesCounters
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
    }
}
