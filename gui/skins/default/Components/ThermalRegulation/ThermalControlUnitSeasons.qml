import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    property int idx: -1

    signal seasonSelected(int season)

    height: 100
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: column.idx
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            onClicked: {
                var clickedItem = modelList.get(index)
                column.seasonSelected(clickedItem.type)
                column.closeColumn()
            }
        }

        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [ThermalControlUnit.Summer,
                         ThermalControlUnit.Winter]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('SEASON', l[i])})
                // restores the right value for the itemList currentIndex property
                // because the append function changes it
                itemList.currentIndex = column.idx
            }
        }
    }
}

