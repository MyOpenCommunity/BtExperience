import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    function getFile(type) {
        if (type === 0)
            return "SourceSelection.qml"
        else if (type === 1)
            return "Amplifier.qml"
    }

    Component.onCompleted: itemList.currentIndex = -1
    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListModel {
        id: listModel

        ListElement {
            name: "source"
            hasChild: true
            description: "Radio | FM 108.7 - Radio Cassadritta"
            status: -1
            type: 0
        }

        ListElement {
            name: "generale camera"
            description: ""
            hasChild: false
            status: -1
            type: 1
        }
        ListElement {
            name: "amplificatore 1"
            description: ""
            status: 0
            hasChild: true
            type: 1
        }
        ListElement {
            name: "amplificatore 2"
            description: ""
            status: 1
            hasChild: true
            type: 1
        }
        ListElement {
            name: "amplificatore 3"
            description: ""
            status: 0
            hasChild: true
            type: 1
        }
    }

    ListView {
        id: itemList
        anchors.fill: parent
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: listModel.get(index)

            active: element.animationRunning === false
            status: itemObject.status
            hasChild: itemObject.hasChild
            description: itemObject.description
            onClicked: element.loadElement(getFile(itemObject.type), itemObject.name, listModel.get(model.index));
        }

        model: listModel
    }
}
