import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: Math.max(1, listView.height)

    onChildDestroyed: {
        listView.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Component.onCompleted: {
        listModel.append({"name": "washing machine",
                             "description": "control disabled",
                             "status": 0,
                             "boxInfoState": "info",
                             "boxInfoText": "32 W",
                             "component": applianceLoad})
        listModel.append({"name": "oven",
                             "description": "control enabled",
                             "status": 1,
                             "boxInfoState": "",
                             "boxInfoText": "",
                             "component": appliance})
        listModel.append({"name": "microwave oven",
                             "description": "detached",
                             "status": 2,
                             "boxInfoState": "",
                             "boxInfoText": "",
                             "component": applianceLoadOff})
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    ListModel {
        id: listModel
    }

    Component {
        id: appliance
        Appliance {}
    }

    Component {
        id: applianceLoad
        ApplianceLoad {}
    }

    Component {
        id: applianceLoadOff
        ApplianceLoadOff {}
    }

    Column {
        PaginatorList {
            id: listView
            currentIndex: -1
            width: element.width
            listHeight: Math.max(1, 50 * listModel.count)
            delegate: MenuItemDelegate {
                name: model.name
                description: model.description
                boxInfoState: model.boxInfoState
                boxInfoText: model.boxInfoText
                status: model.status
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    element.loadColumn(model.component, name)
                }
            }
            model: listModel
        }
    }
}
