import QtQuick 1.1

MenuElement {
    id: element
    height: 150
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
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                element.loadElement(clickedItem.componentFile, clickedItem.name)
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "impianto termico"
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



