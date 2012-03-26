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
            itemObject: scenarioModel.getObject(index)
            onClicked: element.dataModel.scenarioIndex = index
        }

        model: scenarioModel
        ObjectModel {
            id: scenarioModel
            source: element.dataModel.scenarios
        }
    }
}
