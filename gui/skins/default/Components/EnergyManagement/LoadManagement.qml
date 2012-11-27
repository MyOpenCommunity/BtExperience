import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element

    Column {
        PaginatorList {
            id: listView
            elementsOnPage: 3
            delegate: MenuItemDelegate {
                itemObject: listModel.getObject(index)
                name: itemObject.name
                description: boxInfoText === "0" ? qsTr("Disabled") : itemObject.consumption + " " + itemObject.currentUnit
                boxInfoState: privateProps.infoState(itemObject)
                boxInfoText: privateProps.infoText(itemObject)
                status: privateProps.loadStatus(itemObject)
                hasChild: true
                onDelegateClicked: element.loadColumn(appliance, itemObject.name, itemObject)
                Component.onCompleted: {
                    itemObject.requestLoadStatus()
                    itemObject.requestConsumptionUpdateStart()
                }
                Component.onDestruction: itemObject.requestConsumptionUpdateStop()
            }
            model: listModel
        }
    }

    QtObject {
        id: privateProps

        function infoState(obj) {
            if (!obj.hasControlUnit)
                return ""
            if (obj.loadEnabled)
                return "info"
            return "warning"
        }

        function infoText(obj) {
            if (!obj.hasControlUnit)
                return ""
            if (obj.loadEnabled)
                return "1"
            return "0"
        }

        function loadStatus(obj) {
            if (obj.loadStatus === EnergyLoadDiagnostic.Unknown)
                return 0
            else if (obj.loadStatus === EnergyLoadDiagnostic.Ok)
                return 1
            else if (obj.loadStatus === EnergyLoadDiagnostic.Warning)
                return 2
            else if (obj.loadStatus === EnergyLoadDiagnostic.Critical)
                return 3
        }
    }

    Component {
        id: appliance
        Appliance {}
    }

    ObjectModel {
        id: listModel
        filters: [
            {objectId: ObjectInterface.IdEnergyLoad}
        ]
    }
}
