import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: element
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
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                element.loadElement(clickedItem.componentFile, clickedItem.name, clickedItem)
            }
        }
        model: ListModel {
            id: modelList
            ListElement {
                name: "generale"
                componentFile: "Components/VideoDoorEntry/Talk.qml"
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
    }
}
