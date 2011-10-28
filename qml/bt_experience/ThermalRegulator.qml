import QtQuick 1.1

MenuElement {
    id: element
    height: 260
    width: 245

    onChildDestroyed: itemList.currentIndex = -1

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            onClicked: {
                var clickedItem = modelList.get(index)
                element.loadChild(clickedItem.name, clickedItem.componentFile)
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
