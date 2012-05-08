import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
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
            editable: true
            itemObject: scenariosModel.getObject(index)

            selectOnClick: false // we don't want to break the binding for currentIndex
            description: itemObject.description
            onClicked: column.scenarioSelected(itemObject)
        }

        model: scenariosModel
    }

    FilterListModel {
        id: scenariosModel
        source: column.dataModel
    }
}
