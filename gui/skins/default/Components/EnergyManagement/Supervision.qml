import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element

    Column {
        PaginatorList {
            id: listView
            delegate: MenuItemDelegate {
                itemObject: listModel.getObject(index)
                name: itemObject.name
                description: privateProps.getDescription(itemObject)
                status: privateProps.loadStatus(itemObject)
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    element.loadColumn(privateProps.getComponent(itemObject), name, itemObject)
                }
            }
            model: listModel
        }

        MenuItem {
            id: loadDiagnostic
            name: qsTr("load diagnostic")
            state: privateProps.currentIndex === 1 ? "selected" : ""
            hasChild: true
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadColumn(component, name)
            }

            Component {
                id: component
                LoadDiagnostic {}
            }
        }
    }

    onChildDestroyed: privateProps.currentIndex = -1

    QtObject {
        id: privateProps

        property int currentIndex: -1

        function getComponent(obj) {
            if (obj.objectId === ObjectInterface.IdStopAndGo)
                return stopAndGo
            if (obj.objectId === ObjectInterface.IdStopAndGoPlus)
                return stopAndGoPlus
            if (obj.objectId === ObjectInterface.IdStopAndGoBTest)
                return stopAndGoBtest
        }

        function getDescription(obj) {
            if (obj.status === stopAndGo.Closed)
                return qsTr("Closed")
            else if (obj.status === stopAndGo.Opened)
                return qsTr("Open")
            else if (obj.status === stopAndGo.Locked)
                return qsTr("Open - Block")
            else if (obj.status === stopAndGo.ShortCircuit)
                return qsTr("Open - Short Circuit")
            else if (obj.status === stopAndGo.GroundFail)
                return qsTr("Open - Earth Fault")
            else if (obj.status === stopAndGo.Overtension)
                return qsTr("Open - Over Current")
            return qsTr("Unknown")
        }

        function loadStatus(obj) {
            if (obj.status === stopAndGo.Closed)
                return 1
            if (obj.status === stopAndGo.Unknown)
                return 0
            return 3
        }
    }

    Component {
        id: stopAndGo
        StopAndGoMenu {}
    }

    Component {
        id: stopAndGoPlus
        StopAndGoPlus {}
    }

    Component {
        id: stopAndGoBtest
        StopAndGoBtest {}
    }

    ObjectModel {
        id: listModel
        filters: [
            {objectId: ObjectInterface.IdStopAndGo},
            {objectId: ObjectInterface.IdStopAndGoPlus},
            {objectId: ObjectInterface.IdStopAndGoBTest}
        ]
    }
}
