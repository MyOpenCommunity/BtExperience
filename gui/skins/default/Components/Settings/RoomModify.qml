import QtQuick 1.1
import BtObjects 1.0
import "../../js/Stack.js" as Stack
import Components 1.0


MenuColumn {
    id: column
    height: 50 * itemList.count
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }


    ListView {
        id: itemList
        anchors.fill: parent

        currentIndex: -1

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: false
            selectOnClick: true
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "Rinomina"
        }

        ListElement {
            name: "Aggiungi"
        }
    }
}
