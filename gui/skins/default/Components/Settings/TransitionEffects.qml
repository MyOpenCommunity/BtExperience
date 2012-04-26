import QtQuick 1.1
import "../../js/Stack.js" as Stack
import Components 1.0

MenuColumn {
    id: column
    height: Math.max(1, 50 * itemList.count)
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent

        currentIndex: -1

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: false
            selectOnClick: true
            onClicked: {
                Stack.container.animationType = model.name
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "fade"
        }

        ListElement {
            name: "slide"
        }
    }
}
