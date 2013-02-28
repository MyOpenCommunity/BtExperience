import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    property int idx: -1

    signal modalitySelected(int modality)

    height: 200
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: {
            for (var i = 0; i < modelList.count; ++i) {
                if (modelList.get(i).type === column.idx)
                    return i
            }
            return -1
        }
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            onDelegateTouched: {
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


