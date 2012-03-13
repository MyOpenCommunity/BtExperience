import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: programModel.getObject(index)
            active: element.animationRunning === false
            onClicked: element.dataModel.programIndex = index
        }

        model: programModel
        ObjectModel {
            id: programModel
            source: element.dataModel.programs
        }
    }
}
