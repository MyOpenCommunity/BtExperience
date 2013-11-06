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
import "../js/MenuContainer.js" as Script


/**
  \ingroup Core

  \brief A component to manage a group of related menus.

  The MenuContainer component encapsulates logic to show a hierarchical list
  of MenuColumn that may have different sizes and behaviors. Menu items are
  arranged horizontally inside the MenuContainer until their width sum overtakes
  the container width. At that point, first elements are hidden.
  Every item must emit the loadComponent signal to request loading a child
  element. A closeItem signal is used to close the menu item.
  */
Item {
    id: mainContainer

    width: 600
    height: 400

    /// The root element (without scroll, the first column)
    property QtObject rootColumn

    property QtObject rootData: null

    /// the page where the container is placed
    property variant pageObject: undefined

    /// the object that represents the root element (without scroll, the first column)
    property variant rootObject: undefined

    /// the object that represents the current element (the last column open)
    property variant currentObject: undefined

    /// max number of elements in paged menus
    property int elementsOnMenuPage: 8

    property alias clipBehavior: clippingContainer.clip

    /// the menu was closed
    signal closed
    signal rootColumnClicked
    /// during navigation, causes the next MenuColumn to load
    signal loadNextColumn // used for menu navigation, see navigation.js for further details

    /// closes the last MenuColumn
    function closeLastColumn() {
        Script.closeLastItem()
    }

    /// closes all MenuColumn
    function closeAll() {
        Script.closeItem(1)
    }

    Constants {
        id: constants
    }

    // This property is explicitly set to false whenever any operation on columns
    // is requested. This way we filter all inputs on clippingContainer until
    // all pending operations are completed. This avoids the 'double click' bug
    // on different elements in the first column
    //
    // Consider it an implementation detail
    property bool interactive: true

    Item {
        id: clippingContainer

        anchors.fill: parent
        clip: true

        Item {
            id: elementsContainer
            width: 0
            x: 0
            y: 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            property bool animationRunning: defaultanimation.running
            property int currentLevel: -1

            Behavior on x {
                id: animation
                NumberAnimation { id: defaultanimation; duration: constants.elementTransitionDuration }
            }
        }

        MouseArea {
            id: interactivityArea
            anchors.fill: parent
            visible: !interactive
        }
    }

    Component.onCompleted: {
        Script.debugTiming = global.debugTiming
        Script.loadComponent(-1, mainContainer.rootColumn, "", rootData, {}, Script.NO_TITLE)
        mainContainer.rootObject.columnClicked.connect(rootColumnClicked)
    }
}
