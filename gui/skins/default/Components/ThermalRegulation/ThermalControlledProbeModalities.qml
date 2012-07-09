import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    height: 200
    width: 212

    signal modalitySelected(int modality)

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: selectItem()
        interactive: false

        function selectItem() {
            for (var i = 0; i < modelList.count; i++) {
                if (modelList.get(i).type === dataModel.probeStatus)
                    return i;
            }
            return -1
        }

        delegate: MenuItemDelegate {
            name: model.name
            onClicked: {
                var clickedItem = modelList.get(index)
                column.modalitySelected(clickedItem.type)
                column.closeColumn()
            }
        }

        model: ListModel {
            id: modelList

            Component.onCompleted: {
                var l = [ThermalControlledProbe.Auto,
                         ThermalControlledProbe.Antifreeze,
                        ThermalControlledProbe.Manual,
                        ThermalControlledProbe.Off]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('PROBE_STATUS', l[i])})
            }
        }

    }
}


