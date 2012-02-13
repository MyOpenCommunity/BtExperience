import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    signal scenarioSelected(variant obj)

    onScenarioSelected: obj.apply()

    ListView {
        id: itemList
        anchors.fill: parent
        interactive: false

        currentIndex: selectItem()

        function selectItem() {
            for (var i = 0; i < itemList.count; i++) {
                if (itemList.model.getObject(i).selected === true)
                    return i;
            }

            return -1
        }

        delegate: MenuItemDelegate {
            selectOnClick: false // we don't want to break the binding for currentIndex
            active: element.animationRunning === false
            description: model.description
            onClicked: {
                var obj = itemList.model.getObject(model.index)
                element.scenarioSelected(obj)
            }
        }

        model: element.dataModel.scenarios
    }
}
