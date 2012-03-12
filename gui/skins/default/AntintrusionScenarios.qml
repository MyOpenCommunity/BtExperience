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
                if (scenariosModel.getObject(i).selected === true)
                    return i;
            }

            return -1
        }

        delegate: MenuItemDelegate {
            itemObject: scenariosModel.getObject(index)

            selectOnClick: false // we don't want to break the binding for currentIndex
            active: element.animationRunning === false
            description: itemObject.description
            onClicked: element.scenarioSelected(itemObject)
        }

        model: scenariosModel

        ObjectModel {
            id: scenariosModel
            source: element.dataModel
        }
    }
}
