/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1


/**
  \ingroup Core

  \brief A delegate to be used in ListView or PaginatorList.

  A component that let use a MenuItem as delegate inside a ListView.
  */
MenuItem {
    id: itemDelegate

    /// sets this item as selected on clicks
    property bool selectOnClick: true
    /// the model item to be rendered in this delegate
    property variant itemObject

    /// This delegate was clicked
    signal delegateClicked(int index)
    /// This delegate was touched (a touch is a press to be managed like a click)
    signal delegateTouched(int index)

    /// Resets the ListView selection
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

