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
                if (modelList.get(i).type === dataModel.mode) {
                    itemList.currentIndex = i;
                    return;
                }
                itemList.currentIndex = -1
            }
        }

        delegate: MenuItemDelegate {
            selectOnClick: false
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                dataModel.mode = clickedItem.type
            }
        }

        Connections {
            target: dataModel
            onModeChanged: itemList.selectItem()
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "estate"
                type: ThermalControlUnit99Zones.SummerMode
            }

            ListElement {
                name: "inverno"
                type: ThermalControlUnit99Zones.WinterMode
            }
        }

    }
}
