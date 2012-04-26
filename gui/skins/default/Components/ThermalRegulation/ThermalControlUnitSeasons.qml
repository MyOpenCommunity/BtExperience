import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column
    height: 100
    width: 212
    signal seasonSelected(int season)

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
            name: model.name
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                column.seasonSelected(clickedItem.type)
            }
        }

        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [ThermalControlUnit99Zones.Summer,
                         ThermalControlUnit99Zones.Winter]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('SEASON', l[i])})
            }
        }
    }
}

