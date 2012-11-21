import QtQuick 1.1
import Components 1.0
import Components.EnergyManagement 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: element
    width: 212
    height: 150

    // needed for menu navigation
    function targetsKnown() {
        return {
            "Supervision": privateProps.openSupervisionMenu,
        }
    }

    QtObject {
        id: privateProps

        function openSupervisionMenu(navigationData) {
            return _openMenu(0)
        }

        function _openMenu(index) {
            var m = listModel.get(index)
            listView.currentIndex = index
            element.loadColumn(m.component, m.name)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
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
