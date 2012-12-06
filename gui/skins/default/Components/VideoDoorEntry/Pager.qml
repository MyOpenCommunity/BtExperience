import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    SystemsModel {id: systemsModel; systemId: Container.IdVideoDoorEntry }
    ObjectModel {
        id: modelList
        filters: [{objectId: ObjectInterface.IdIntercom}]
    }

    Column {
        MenuItem {
            name: qsTr("pager")
            hasChild: false
            height: controlCall.height
            ControlCall {
                id: controlCall
                dataObject: modelList.getObject(0)
            }
        }
    }
}
