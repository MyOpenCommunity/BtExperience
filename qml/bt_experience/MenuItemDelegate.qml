import QtQuick 1.1


MenuItem {
    id: itemDelegate
    name: model.name
    hasChild: model.componentFile !== undefined && model.componentFile !== ""

    signal delegateClicked(int index)

    onClicked: {
        // Avoid destroy and recreate the items if the element is already selected
        if (itemDelegate.ListView.isCurrentItem)
            return

        itemList.currentIndex = model.index
        itemDelegate.delegateClicked(model.index)
    }

    states: State {
        name: "delegateselected"
        extend: "selected"
        when: itemDelegate.ListView.isCurrentItem
    }
}

