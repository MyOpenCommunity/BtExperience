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

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    ListModel {
        id: listModel
        ListElement {
            name: "Stop and Go"
            description: "chiuso"
            status: 1
        }
        ListElement {
            name: "Stop and Go Plus"
            description: "chiuso"
            status: 1
        }
        ListElement {
            name: "Stop and Go Btest"
            description: "aperto - sovratensione"
            status: 0
        }
    }

    Column {
        PaginatorList {
            id: listView
            currentIndex: -1
            width: element.width
            listHeight: listModel.count * 50
            delegate: MenuItemDelegate {
                name: model.name
                description: model.description
                status: model.status
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    element.loadElement("Components/EnergyManagement/StopAndGo.qml", name)
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
                element.loadElement("Components/EnergyManagement/LoadDiagnostic.qml", name)
            }
        }
    }
}
