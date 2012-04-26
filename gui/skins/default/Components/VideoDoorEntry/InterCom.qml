import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    ObjectModel {
        id: modelList
        filters: [{objectId: ObjectInterface.IdIntercom}]
    }

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: modelList.size * 50
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            hasChild: true
            onDelegateClicked: column.loadColumn(talk, name, itemObject)
        }
        model: modelList

        onCurrentPageChanged: column.closeChild()
    }

    Component {
        id: talk
        Talk {}
    }
}
