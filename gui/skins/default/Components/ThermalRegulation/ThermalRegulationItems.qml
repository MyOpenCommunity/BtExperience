import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
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
            name: model.name
            hasChild: true
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                column.loadElement(clickedItem.componentFile, clickedItem.name)
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "impianto termico"
                componentFile: "Components/ThermalRegulation/ThermalRegulator.qml"
            }

            ListElement {
                name: "climatizzazione"
                componentFile: "Components/ThermalRegulation/AirConditioning.qml"
            }

            ListElement {
                name: "sensori"
                componentFile: "ThermalProbe.qml"
            }
        }

    }
}



