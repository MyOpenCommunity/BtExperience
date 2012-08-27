import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: energiesCounters.getObject(index)
            hasChild: true
            onClicked: column.loadColumn(thresholdsComponent, itemObject.name, itemObject)
        }

        model: energiesCounters
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
    }

    Component {
        id: thresholdsComponent
        SettingsEnergyThresholdsFamily {

        }
    }
}
