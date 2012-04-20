import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    ObjectModel {
        id: modelList
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: modelList.size * 50
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            onDelegateClicked: {
                var page = Stack.openPage("VideoCamera.qml", {"camera": itemObject})
            }
        }
        model: modelList

        onCurrentPageChanged: column.closeChild()
    }
}
