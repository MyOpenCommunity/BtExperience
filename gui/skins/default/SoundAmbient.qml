import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    ListModel {
        id: listModel
        ListElement {
            name: "sorgente"
            description: "radio | FM 105 - Radio 105"
            status: false
            hasChild: false
        }
        ListElement {
            name: "generale camera"
            description: ""
            hasChild: false
            status: false
        }
        ListElement {
            name: "amplificatore 1"
            description: ""
            status: true
            hasChild: true
        }
        ListElement {
            name: "amplificatore 2"
            description: ""
            status: false
            hasChild: true
        }
        ListElement {
            name: "amplificatore 3"
            description: ""
            status: false
            hasChild: true
        }
    }

    ListView {
        id: itemList
        anchors.fill: parent
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: listModel.get(index)

            active: element.animationRunning === false
            hasChild: itemObject.hasChild
            description: itemObject.description
            onClicked: element.loadElement("Amplifier.qml", itemObject.name, listModel.get(model.index));
        }

        model: listModel
    }
}
