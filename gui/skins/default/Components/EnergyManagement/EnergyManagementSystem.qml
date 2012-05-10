import QtQuick 1.1
import Components 1.0
import Components.EnergyManagement 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: element
    width: 212
    height: 150

    onChildDestroyed: {
        listView.currentIndex = -1
    }

    Component.onCompleted: {
        listModel.append({"name": qsTr("systems supervision"), "component": supervision})
        listModel.append({"name": qsTr("consumption/production display"), "component": supervision}) // treated differently
        listModel.append({"name": qsTr("load management"), "component": loadManagement})
    }

    ListView {
        id: listView
        interactive: false
        currentIndex: -1
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onClicked: {
                if (model.name == qsTr("consumption/production display") )
                    Stack.openPage("Components/EnergyManagement/EnergyDataOverview.qml")
                else
                    element.loadColumn(model.component, model.name)
            }
        }
        model: listModel

        ListModel {
            id: listModel
        }

        Component {
            id: supervision
            Supervision {
            }
        }

        Component {
            id: loadManagement
            LoadManagement {
            }
        }
    }
}
