import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        width: parent.width
        elementsOnPage: 8
        listHeight: elementsOnPage * 50
        delegate: MenuItemDelegate {
            editable: true
            name: model.name
            status: model.status
            description: model.description
        }

        model: listModel
    }

    ListModel {
        id: listModel
        ListElement {
            name: "Lavatrice"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "Forno cucina"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "Frigorifero"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "Microonde"
            description: "attenzione"
            status: 0
        }
        ListElement {
            name: "Congelatore"
            description: "pericolo"
            status: 0
        }
        ListElement {
            name: "Lavastoviglie"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "Forno taverna"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "fono taverna"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "fono bagno"
            description: "OK"
            status: 1
        }
        ListElement {
            name: "Ferro da stiro"
            description: "OK"
            status: 1
        }
    }
}
