import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: 100
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: selectItem()
        interactive: false

        function selectItem() {
            for (var i = 0; i < modelList.count; i++) {
                if (modelList.get(i).type === dataModel.season)
                    return i;
            }
            return -1
        }

        delegate: MenuItemDelegate {
            selectOnClick: false
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                dataModel.season = clickedItem.type
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "estate"
                type: ThermalControlUnit99Zones.Summer
            }

            ListElement {
                name: "inverno"
                type: ThermalControlUnit99Zones.Winter
            }
        }

    }
}
