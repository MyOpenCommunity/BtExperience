import QtQuick 1.1

MenuElement {
    id: element
    height: 250
    width: 212

    onChildDestroyed: itemList.currentIndex = -1

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                element.loadChild(clickedItem.name, clickedItem.componentFile)
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
                name: "unità centrale"
                componentFile: "ThermalCentralUnit.qml"
            }

            ListElement {
                name: "zona giorno"
                componentFile: "ThermalControlledProbe.qml"
            }

            ListElement {
                name: "zona notte"
                componentFile: "ThermalControlledProbe.qml"
            }

            ListElement {
                name: "zona taverna"
                componentFile: "ThermalControlledProbe.qml"
            }

            ListElement {
                name: "zona studio"
                componentFile: "ThermalControlledProbe.qml"
            }
        }
    }

}
