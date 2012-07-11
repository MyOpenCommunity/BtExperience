import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    property variant idx: -1

    signal modalitySelected(variant obj)

    height: Math.max(1, 50 * itemList.count)
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: {
            for (var i = 0; i < model.count; ++i) {
                if (model.getObject(i) === column.idx)
                    return i
            }
            return -1
        }
        interactive: false

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
