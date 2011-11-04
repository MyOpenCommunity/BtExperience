import QtQuick 1.1

MenuElement {
    id: element
    height: 200
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

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
                name: "impianto termico 1"
                componentFile: "ThermalRegulator.qml"
            }

            ListElement {
                name: "impianto termico 2"
                componentFile: "ThermalRegulator.qml"
            }

            ListElement {
                name: "climatizzazione"
                componentFile: "AirConditioning.qml"
            }

            ListElement {
                name: "sensori"
                componentFile: "ThermalProbe.qml"
            }
        }

    }
}



