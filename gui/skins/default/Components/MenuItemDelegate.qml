import QtQuick 1.1


MenuItem {
    id: itemDelegate

    property bool selectOnClick: true
    property variant itemObject

    signal delegateClicked(int index)
    signal delegateTouched(int index)

    function resetSelection() {
        itemDelegate.ListView.view.currentIndex = -1
    }

    name: itemObject.name

    onEditCompleted: itemObject.name = name
    onClicked: {
        if (!itemDelegate.editable) // only touches, no clicks
            return
        // Avoid destroy and recreate the items if the element is already selected
        if (itemDelegate.ListView.isCurrentItem)
            return
        if (selectOnClick)
            itemDelegate.ListView.view.currentIndex = model.index
        itemDelegate.delegateClicked(model.index)
    }
    onTouched: {
        if (itemDelegate.editable) // only clicks, no touches
            return
        // Avoid destroy and recreate the items if the element is already selected
        if (itemDelegate.ListView.isCurrentItem)
            return
        if (selectOnClick)
            itemDelegate.ListView.view.currentIndex = model.index
        itemDelegate.delegateTouched(model.index)
    }

    // See the comment on MenuItem about the states use.
    states: State {
        name: "_delegateselected"
        extend: "_selected"
        when: itemDelegate.ListView.isCurrentItem
    }
}

