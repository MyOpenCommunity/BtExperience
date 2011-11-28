import QtQuick 1.1
import bticino 1.0

MenuElement {
    id: element
    height: 200
    width: 212

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: selectItem()
        interactive: false

        function selectItem() {
            for (var i = 0; i < modelList.count; i++) {
                if (modelList.get(i).type === dataModel.probeStatus) {
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
                dataModel.probeStatus = clickedItem.type
            }
        }

        Connections {
            target: dataModel
            onProbeStatusChanged: itemList.selectItem()
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "auto"
                type: ThermalControlledProbe.Auto
            }

            ListElement {
                name: "antigelo"
                type: ThermalControlledProbe.Antifreeze
            }

            ListElement {
                name: "manuale"
                type: ThermalControlledProbe.Manual
            }

            ListElement {
                name: "off"
                type: ThermalControlledProbe.Off
            }

        }

    }
}


