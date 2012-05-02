import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: listView.height + loadDiagnostic.height

    onChildDestroyed: {
        listView.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Component.onCompleted: {
        listModel.append({"name": "Stop and Go", "description": "chiuso",
                             "status": 1,
                             "component": stopAndGo})
        listModel.append({"name": "Stop and Go Plus",
                             "description": "chiuso",
                             "status": 1,
                             "component": stopAndGoPlus})
        listModel.append({"name": "Stop and Go Btest",
                             "description": "aperto - sovratensione",
                             "status": 0,
                             "component": stopAndGoBtest})
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    ListModel {
        id: listModel
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

    Column {
        PaginatorList {
            id: listView
            currentIndex: -1
            width: element.width
            listHeight: Math.max(1, 50 * listModel.count)
            delegate: MenuItemDelegate {
                name: model.name
                description: model.description
                status: model.status
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    element.loadColumn(model.component, name)
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
                listView.currentIndex = -1
                privateProps.currentIndex = 1
                element.loadColumn(component, name)
            }

            Component {
                id: component
                LoadDiagnostic{}
            }
        }
    }
}
