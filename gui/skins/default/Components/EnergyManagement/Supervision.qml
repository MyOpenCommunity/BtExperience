import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: 150

    onChildDestroyed: {
        listView.currentIndex = -1
    }

    ListView {
        id: listView
        interactive: false
        currentIndex: -1
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            description: model.description
            status: model.status
            hasChild: true
        }
        model: listModel
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
}
