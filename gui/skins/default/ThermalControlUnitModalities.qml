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
                    if (modalitiesModel.getObject(i).objectId === element.dataModel.currentModality.objectId)
                        return i;
                }
            }
            return -1
        }

        delegate: MenuItemDelegate {
            itemObject: modalitiesModel.getObject(index)
            active: element.animationRunning === false
            onClicked: element.modalitySelected(itemObject)
        }
        model: modalitiesModel

        ObjectModel {
            id: modalitiesModel
            source: element.dataModel.modalities
        }
    }
}
