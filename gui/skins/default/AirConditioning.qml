import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: fakeModel.count * 50

    onChildDestroyed: ambientList.currentIndex = -1

    // TODO: fake model
    ListModel {
        id: fakeModel
        ListElement {
            name: "soggiorno"
            advanced: true
        }

        ListElement {
            name: "cucina"
            advanced: false
        }
    }

    ListView {
        id: ambientList
        anchors.fill: parent
        model: fakeModel
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: fakeModel.get(index)

            active: element.animationRunning === false
            hasChild: true
            onClicked: loadElement(itemObject.advanced ? "AdvancedSplit.qml" : "BasicSplit.qml", name)
        }
    }
}
