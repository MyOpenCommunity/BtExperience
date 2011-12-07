import QtQuick 1.1

MenuElement {
    id: element
    height: 150
    width: 212

    signal programSelected(string programName)

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            onDelegateClicked: {
                var clickedItem = itemList.model.getObject(model.index)

                element.closeElement()
                element.programSelected(clickedItem.name)
                clickedItem.apply()
            }
        }

        model: element.dataModel.menuItemList

        ObjectModel {
            id: modelList
        }
    }
}

