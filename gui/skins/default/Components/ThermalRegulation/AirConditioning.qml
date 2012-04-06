import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: fakeModel.count * 50

    onChildDestroyed: ambientList.currentIndex = -1
    Component.onCompleted: ambientList.currentIndex = -1

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

            hasChild: true
            onClicked: loadElement("Components/ThermalRegulation/" + (itemObject.advanced ? "AdvancedSplit.qml" : "BasicSplit.qml"), name)
        }
    }
}
