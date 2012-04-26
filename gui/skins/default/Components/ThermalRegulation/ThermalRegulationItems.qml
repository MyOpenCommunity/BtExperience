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
                column.loadColumn(clickedItem.component, clickedItem.name)
            }
        }

        model: modelList

    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Thermal Regulator"), "component": thermalRegulator})
            modelList.append({"name": qsTr("Air Conditioning"), "component": airConditioning})
            modelList.append({"name": qsTr("Sensors"), "component": thermalProbe})
        }
    }

    Component {
        id: thermalRegulator
        ThermalRegulator {}
    }

    Component {
        id: airConditioning
        AirConditioning {}
    }

    Component {
        id: thermalProbe
        Item {}
    }
}



