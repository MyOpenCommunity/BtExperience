import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            editable: true
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
