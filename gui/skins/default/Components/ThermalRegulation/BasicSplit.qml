import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: fakeModel.count * 50

    onChildDestroyed: programList.currentIndex = -1

    ListModel {
        id: fakeModel
        ListElement {
            name: "comando 1"
        }
        ListElement {
            name: "comando 2"
        }
        ListElement {
            name: "off"
        }
    }

    ListView {
        id: programList
        anchors.fill: parent
        interactive: false
        model: fakeModel

        delegate: MenuItemDelegate {
            itemObject: fakeModel.get(index)
            hasChild: name !== "off"
            onClicked: console.log("Clicked on program " + name)
        }
    }
}
