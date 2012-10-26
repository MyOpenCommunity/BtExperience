import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: energiesCounters.getObject(index)
            property variant rateObject: itemObject.rate
            hasChild: true
            description: rateObject ? qsTr("%1 %2/%3").arg(rateObject.rate).arg(rateObject.currencySymbol).arg(rateObject.measureUnit) : "" // +  "0,24 €/w"
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
