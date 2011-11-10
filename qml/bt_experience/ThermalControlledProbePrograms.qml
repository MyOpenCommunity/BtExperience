import QtQuick 1.1

MenuElement {
    id: element
    height: 200
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

            onPressed: {
                itemHighlighed.sourceComponent = menuItemComponent
                itemHighlighed.item.state = "selected"
                itemHighlighed.item.name = itemPressed.name
                itemHighlighed.item.hasChild = itemPressed.hasChild
                itemHighlighed.item.status = itemPressed.status
                itemHighlighed.item.x = itemPressed.x + element.x - 5
                itemHighlighed.item.y = itemPressed.y + element.y - 2
            }

            onReleased: {
                itemHighlighed.sourceComponent = undefined
            }

            Component {
                id: menuItemComponent
                MenuItem {
                    width: 222
                    height: 55
                }
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


