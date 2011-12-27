import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    signal modalitySelected(variant obj)

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false
        property bool transparent: true

        delegate: MenuItemDelegate {
            onClicked: {
                var obj = itemList.model.getObject(model.index)
                element.modalitySelected(obj)
            }
        }

        model: element.dataModel.modalities
    }
}
