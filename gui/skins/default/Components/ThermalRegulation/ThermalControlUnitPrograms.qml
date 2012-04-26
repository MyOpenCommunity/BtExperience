import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column
    height: Math.max(1, 50 * itemList.count)
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: programModel.getObject(index)
            onClicked: column.dataModel.programIndex = index
        }

        model: programModel
        ObjectModel {
            id: programModel
            source: column.dataModel.programs
        }
    }
}
