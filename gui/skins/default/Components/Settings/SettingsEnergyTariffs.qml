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
            itemObject: energiesRates.getObject(index)
            hasChild: true
            description: itemObject.rate.toFixed(itemObject.displayDecimals) + " " + itemObject.currencySymbol + "/" + itemObject.measureUnit
            onClicked: column.loadColumn(setTariffsComponent, itemObject.name, itemObject)
        }

        onCurrentPageChanged: column.closeChild()
        model: energiesRates
    }

    ObjectModel {
        id: energiesRates
        filters: [{objectId: ObjectInterface.IdEnergyRate}]
    }

    Component {
        id: setTariffsComponent
        SettingsEnergySetTariffs {

        }
    }
}
