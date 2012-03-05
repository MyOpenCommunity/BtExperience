import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * (itemList.count + 1)
    width: 212

    MenuItem {
        id: sourceItem
        active: element.animationRunning === false
        name: qsTr("source")
        hasChild: true
        description: "Radio | FM 108.7 - Radio Cassadritta"
        onClicked: element.loadElement("SourceSelection.qml", qsTr("source"))
    }

    ListModel {
        id: listModel

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
        width: 212
        height: model.count * 50
        anchors.top: sourceItem.bottom
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
