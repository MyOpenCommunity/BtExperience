import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: energiesCounters.getObject(index)
            hasChild: true
            description: "0,24 €/w"
            onClicked: column.loadColumn(setTariffsComponent, itemObject.name, itemObject)
        }

        model: energiesCounters
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
    }

    Component {
        id: setTariffsComponent
        SettingsEnergySetTariffs {

        }
    }
}
