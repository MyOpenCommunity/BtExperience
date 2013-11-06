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
import "../js/navigation.js" as Navigation
import "../js/navigationconstants.js" as NavigationConstants


/**
  \ingroup Core

  \brief A component to group all menu items at the same level.

  The MenuColumn component encapsulates logic to manage a group of menu items.
  It defines logic to manage the MenuColumn when the MenuContainer requests to
  do so. It contains the navigation logic to open a specific MenuItem.
  It also implements the part of the animation logic.
  */
Item {
    id: column

    /**
      Loads a sub-element.

      @param type:Item component The submenu to load
      @param type:string title The title to show on MenuTitle component
      @param type:object model The model object to pass to the submenu
      @param type:array properties The properties to be passed to the submenu at creation
      */
    function loadColumn(component, title, model, properties) {
        column.loadComponent(menuLevel, component, title, model, properties)
    }

    /// Close the column itself and its children
    function closeColumn() {
        column.closeItem(menuLevel)
    }

    /// Close the child's element (if present)
    function closeChild() {
        column.closeItem(menuLevel + 1)
    }

    /**
      Returns the list of callbacks for known navigation targets
      @return type:array a list of callbacks to be called by the navigation target logic
      */
    function targetsKnown() {
        return []
    }

    /**
      Returns if navigation target for this menu level is known or not
      @return is target known?
      */
    function isTargetKnown() {
        var navigationTarget = Navigation.getNavigationTarget(pageObject.navigationTarget, column.menuLevel)

        // no target to navigate to, target is unknown
        if (navigationTarget === undefined)
            return false

        // checks if navigationTarget is known or not
        var targets = column.targetsKnown()
        if (navigationTarget in targets)
            return true

        // it is not known
        return false
    }

    // checks if the need for opening a menu arose
    // see navigation.js for further details
    /// if a navigation target is set, tries to navigate where requested
    function navigate() {
        var navigationTarget = Navigation.getNavigationTarget(pageObject.navigationTarget, column.menuLevel)

        if (navigationTarget === undefined)
            return

        var targets = column.targetsKnown()
        if (navigationTarget in targets) {
            var openMenuResult = targets[navigationTarget](pageObject.navigationData)

            if (openMenuResult === NavigationConstants.NAVIGATION_IN_PROGRESS)
                return // further processing needed

            if (openMenuResult < 0)
                console.log("MenuColumn.navigate error. Navigation target: " + navigationTarget + ". Navigation data: " + pageObject.navigationData + ". Error code: " + openMenuResult)
        }
        else {
            console.log("MenuColumn.navigate error. Navigation target: " + navigationTarget + " unknown. Navigation data: " + pageObject.navigationData + ".")
        }

        // resets navigation
        column.pageObject.navigationTarget = 0
        column.pageObject.navigationData = undefined
    }

    // The signals captured from the MenuContainer to create/close child or the element
    // itself.
    signal closeItem(int menuLevel)
    signal columnClicked()
    signal loadComponent(int menuLevel, variant component, string title, variant dataModel, variant properties)
    signal destroyed()

    /// the page where the element is placed
    property variant pageObject: undefined

    /// max number of elements in paged menus
    property int elementsOnMenuPage: 8

    // Signals emitted from the container

    // This signal is emitted from the MenuContainer when the requested child
    // is loaded (the child itself can be retrieved from the homonymous property)
    property Item child: null
    signal childLoaded

    // This signal is emitted from the MenuContainer when the child is destroyed
    signal childDestroyed

    // Supreme HACK: we rely on parent being MenuContainer.elementsContainer
    // TODO: find a better way to fetch currentLevel from MenuContainer
    property bool isLastColumn: menuLevel === parent.currentLevel

    // private stuff
    property int menuLevel: -1

    property bool enableAnimation: true
    property bool animationRunning: defaultanimation.running

    // Needed to properly set the shadow (MenuShadow) size.
    width: childrenRect.width
    height: childrenRect.height

    Constants {
        id: constants
    }

    Behavior on x {
        enabled: column.enableAnimation
        NumberAnimation { id: defaultanimation; duration: constants.elementTransitionDuration }
    }

    Behavior on opacity {
        enabled: column.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration }
    }

    property QtObject dataModel: null

    Component.onDestruction: column.destroyed()
}

