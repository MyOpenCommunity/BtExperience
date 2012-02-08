import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    signal scenarioSelected(variant obj)

    ListView {
        id: itemList
        anchors.fill: parent
        interactive: false


        delegate: MenuItemDelegate {
            description: model.description
            onClicked: {
                var obj = itemList.model.getObject(model.index)
                element.scenarioSelected(obj)
            }
        }

        model: element.dataModel
    }
}
