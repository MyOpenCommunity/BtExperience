import QtQuick 1.1

MenuElement {
    id: element
    height: 150
    width: 212

    signal programSelected(string programName)

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                element.programSelected(clickedItem.name)
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "P1"
            }

            ListElement {
                name: "P2"
            }

            ListElement {
                name: "P3"
            }
        }

    }
}

