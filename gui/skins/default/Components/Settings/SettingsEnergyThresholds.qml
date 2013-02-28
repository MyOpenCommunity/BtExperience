import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: EnergyData.Electricity}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Column {
        ControlSwitch {
            text: qsTr("alerts %1").arg(global.guiSettings.energyThresholdBeep ? qsTr("enabled") : qsTr("disabled"))
            status: global.guiSettings.energyThresholdBeep ? 0 : 1
            onPressed: global.guiSettings.energyThresholdBeep = !global.guiSettings.energyThresholdBeep
        }

        PaginatorList {
            id: paginator
            delegate: MenuItemDelegate {
                itemObject: energiesCounters.getObject(index)
                hasChild: true
                onDelegateTouched: column.loadColumn(thresholdsComponent, itemObject.name, itemObject)
            }

            elementsOnPage: elementsOnMenuPage - 1
            onCurrentPageChanged: column.closeChild()
            model: energiesCounters
        }
    }

    Component {
        id: thresholdsComponent
        SettingsEnergySetThresholds {

        }
    }
}
