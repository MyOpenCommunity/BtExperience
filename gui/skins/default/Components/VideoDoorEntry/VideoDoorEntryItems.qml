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
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    ObjectModel {
        id: intercomPlaceModel
        containers: [systemsModel.systemUii]
        source: intercomModel.getObject(0).externalPlaces
    }

    ObjectModel {
        id: cctvPlaceModel
        containers: [systemsModel.systemUii]
        source: cctvModel.getObject(0).externalPlaces
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
            if (cctvPlaceModel.count > 0)
                modelList.append({"name": qsTr("video control"), "component": cctv})
            if (intercomPlaceModel.count > 0)
                modelList.append({"name": qsTr("intercom"), "component": intercom})
            if (intercomModel.count > 0 && intercomModel.getObject(0).pagerConfigured)
                modelList.append({"name": qsTr("pager"), "component": pager})
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
