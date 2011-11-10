import QtQuick 1.1


MenuItem {
    id: itemDelegate
    hasChild: model.componentFile !== undefined && model.componentFile !== ""
    name: model.name

    signal clicked(int index)
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Avoid destroy and recreate the items if the element is already selected
            if (itemDelegate.ListView.isCurrentItem)
                return

            itemList.currentIndex = model.index
            itemDelegate.clicked(model.index)
        }
    }

    states: State {
        name: "delegateselected"
        extend: "selected"
        when: itemDelegate.ListView.isCurrentItem
    }
}

