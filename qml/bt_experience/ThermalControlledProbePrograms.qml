import QtQuick 1.1

MenuElement {
    id: element
    height: 260
    width: 245

    signal programSelected(string programName)

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            showRightArrow: false
            onClicked: {
                var clickedItem = modelList.get(index)
                element.programSelected(clickedItem.name)
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "auto"
            }

            ListElement {
                name: "antigelo"
            }

            ListElement {
                name: "manuale"
            }

            ListElement {
                name: "off"
            }

        }

    }
}


