import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    height: Math.max(1, 50 * itemList.count)
    width: 212

    signal modalitySelected(variant obj)

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: selectItem()
        interactive: false

        function selectItem() {
            if (column.dataModel.currentModality) {
                for (var i = 0; i < itemList.count; i++) {
                    if (modalitiesModel.getObject(i).objectId === column.dataModel.currentModality.objectId)
                        return i;
                }
            }
            return -1
        }

        delegate: MenuItemDelegate {
            itemObject: modalitiesModel.getObject(index)
            onClicked: {
                column.modalitySelected(itemObject)
                column.closeColumn()
            }
        }
        model: modalitiesModel
    }

    ObjectModel {
        id: modalitiesModel
        source: column.dataModel.modalities
    }
}
