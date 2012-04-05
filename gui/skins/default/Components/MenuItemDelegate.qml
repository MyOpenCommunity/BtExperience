import QtQuick 1.1


MenuItem {
    id: itemDelegate

    property bool selectOnClick: true
    property variant itemObject
    name: itemObject.name

    signal delegateClicked(int index)

    onClicked: {
        // Avoid destroy and recreate the items if the element is already selected
        if (itemDelegate.ListView.isCurrentItem)
            return

        if (selectOnClick)
            itemDelegate.ListView.view.currentIndex = model.index
        itemDelegate.delegateClicked(model.index)
    }

    states: State {
        name: "delegateselected"
        extend: "selected"
        when: itemDelegate.ListView.isCurrentItem
    }
}

