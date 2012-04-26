import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: 150

    onChildDestroyed: {
        listView.currentIndex = -1
    }

    Component.onCompleted: {
        listModel.append({"name": qsTr("systems supervision"), "component": "Components/EnergyManagement/Supervision.qml"})
        listModel.append({"name": qsTr("consumption/production display"), "component": "Components/EnergyManagement/Supervision.qml"})
        listModel.append({"name": qsTr("load management"), "component": "Components/EnergyManagement/Supervision.qml"})
    }

    ListView {
        id: listView
        interactive: false
        currentIndex: -1
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onClicked: element.loadElement(model.component, model.name)
        }
        model: listModel
    }

    ListModel {
        id: listModel
    }
}
