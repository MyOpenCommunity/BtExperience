import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: 200
        delegate: MenuItemDelegate {
            itemObject: model
            hasChild: true
        }
        model: ListModel {
            id: fakeModel
            ListElement {
                name: "generale"
            }
            ListElement {
                name: "cucina"
            }
            ListElement {
                name: "camera"
            }
            ListElement {
                name: "box"
            }
        }

        onCurrentPageChanged: column.closeChild()
    }
}
