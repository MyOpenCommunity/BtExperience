import QtQuick 1.1
import Components 1.0
import Components.EnergyManagement 1.0

MenuColumn {
    id: element
    width: 212
    height: 150

    // redefined to implement menu navigation
    function openMenu(navigationTarget) {
        if (navigationTarget === "Supervision") {
            var m = listModel.get(0)
            listView.currentIndex = 0
            element.loadColumn(m.component, m.name)
            return 0
        }
        return -2 // wrong target
    }

    onChildDestroyed: {
        listView.currentIndex = -1
    }

    ListView {
        id: listView
        interactive: false
        currentIndex: -1
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onClicked: element.loadColumn(model.component, model.name)
        }
        model: listModel
    }

    ListModel {
        id: listModel
        Component.onCompleted: {
            listModel.append({"name": qsTr("systems supervision"), "component": supervision})
            listModel.append({"name": qsTr("consumption/production"), "component": energyOverview})
            listModel.append({"name": qsTr("load management"), "component": loadManagement})
        }
    }

    Component {
        id: supervision
        Supervision {}
    }

    Component {
        id: loadManagement
        LoadManagement {}
    }

    Component {
        id: energyOverview
        EnergyOverview {}
    }
}
