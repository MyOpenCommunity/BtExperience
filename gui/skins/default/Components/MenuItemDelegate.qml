import QtQuick 1.1


MenuItem {
    id: itemDelegate

    property bool selectOnClick: true
    property variant itemObject

    signal delegateClicked(int index)

    name: itemObject.name

    onEditCompleted: itemObject.name = name
    onClicked: {
        // Avoid destroy and recreate the items if the element is already selected
        if (itemDelegate.ListView.isCurrentItem)
            return

        if (selectOnClick)
            itemDelegate.ListView.view.currentIndex = model.index
        itemDelegate.delegateClicked(model.index)
    }

    // See the comment on MenuItem about the states use.
    states: State {
        name: "_delegateselected"
        extend: "_selected"
        when: itemDelegate.ListView.isCurrentItem
    }
}

