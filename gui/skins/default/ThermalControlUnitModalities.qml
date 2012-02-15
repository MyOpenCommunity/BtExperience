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
        currentIndex: selectItem()
        interactive: false

        function selectItem() {
            if (element.dataModel.currentModality) {
                for (var i = 0; i < itemList.count; i++) {
                    if (itemList.model.getObject(i).objectId === element.dataModel.currentModality.objectId)
                        return i;
                }
            }
            return -1
        }

        delegate: MenuItemDelegate {
            itemObject: element.dataModel.modalities.getObject(index)
            active: element.animationRunning === false
            onClicked: element.modalitySelected(itemObject)
        }

        model: element.dataModel.modalities
    }
}
