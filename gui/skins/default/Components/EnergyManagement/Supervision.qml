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
            {objectId: ObjectInterface.IdStopAndGo},
            {objectId: ObjectInterface.IdStopAndGoPlus},
            {objectId: ObjectInterface.IdStopAndGoBTest}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: loadDiagnosticModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            id: loadDiagnostic
            name: qsTr("load diagnostic")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            enabled: loadDiagnosticModel.count > 0
            onClicked: {
                paginator.currentIndex = -1
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadColumn(component, name)
            }

            Component {
                id: component
                LoadDiagnostic {}
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: -1
            onCurrentPageChanged: element.closeChild()
            delegate: MenuItemDelegate {
                itemObject: listModel.getObject(index)
                name: itemObject.name
                description: privateProps.getDescription(itemObject)
                status: privateProps.loadStatus(itemObject)
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    element.loadColumn(mapping.getComponent(itemObject.objectId), name, itemObject)
                }
            }
            model: listModel
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1

        function getDescription(obj) {
            if (obj.status === StopAndGo.Closed)
                return qsTr("Closed")
            else if (obj.status === StopAndGo.Opened)
                return qsTr("Open")
            else if (obj.status === StopAndGo.Locked)
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
            if (obj.status === StopAndGo.Closed)
                return 1
            if (obj.status === StopAndGo.Unknown)
                return 0
            return 3
        }
    }

    BtObjectsMapping { id: mapping }
}
