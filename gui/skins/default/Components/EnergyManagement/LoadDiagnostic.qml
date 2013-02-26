import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdSupervision }

    ObjectModel {
        id: listModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
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
            onCurrentPageChanged: element.closeChild()
            delegate: MenuItemDelegate {
                itemObject: listModel.getObject(index)
                name: itemObject.name
                description: privateProps.getDescription(itemObject)
                status: privateProps.loadStatus(itemObject)
                hasChild: false
                Component.onCompleted: itemObject.requestLoadStatus()
            }
            model: listModel
        }
    }

    QtObject {
        id: privateProps

        function getDescription(obj) {
            if (obj.status === StopAndGo.Closed)
                return qsTr("Closed")
            else if (obj.status === StopAndGo.Opened)
                return qsTr("Open")
            else if (obj.status === StopAndGo.Blocked)
                return qsTr("Open - Block")
            else if (obj.status === StopAndGo.ShortCircuit)
                return qsTr("Open - Short Circuit")
            else if (obj.status === StopAndGo.GroundFail)
                return qsTr("Open - Earth Fault")
            else if (obj.status === StopAndGo.Overtension)
                return qsTr("Open - Over Current")
            return qsTr("Unknown")
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
}
