import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log


MenuColumn {
    id: column

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    SystemsModel {id: systemsModel; systemId: Container.IdVideoDoorEntry }
    ObjectModel {
        id: intercomModel
        filters: [{"objectId": ObjectInterface.IdIntercom}]
    }

    ObjectModel {
        id: extPlaceModel
        containers: [systemsModel.systemUii]
        source: intercomModel.getObject(0).externalPlaces
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                column.loadColumn(clickedItem.component, clickedItem.name)
            }
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("video control"), "component": cctv})
            if (extPlaceModel.count > 0) {
                modelList.append({"name": qsTr("intercom"), "component": intercom})
                modelList.append({"name": qsTr("pager"), "component": pager})
            }
        }
    }

    Component {
        id: cctv
        CCTV {}
    }

    Component {
        id: intercom
        InterCom {}
    }

    Component {
        id: pager
        Pager {}
    }
}
