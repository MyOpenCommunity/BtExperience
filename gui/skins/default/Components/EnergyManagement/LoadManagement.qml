import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdLoadControl }

    ObjectModel {
        id: listModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadWithControlUnit},
            {objectId: ObjectInterface.IdLoadWithoutControlUnit}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    Column {
        PaginatorList {
            id: paginator
            currentIndex: -1
            onCurrentPageChanged: closeChild()
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
}
