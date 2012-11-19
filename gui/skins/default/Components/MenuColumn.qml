import QtQuick 1.1
import "../js/navigation.js" as Navigation
import "../js/navigationconstants.js" as NavigationConstants


Item {
    id: column
    // Public functions

    // load of a sub-element
    function loadColumn(component, title, model, properties) {
        column.loadComponent(menuLevel, component, title, model, properties)
    }

    // Close the column itself and its children
    function closeColumn() {
        column.closeItem(menuLevel)
    }

    // Close the child's element (if present)
    function closeChild() {
        column.closeItem(menuLevel + 1)
    }

    function isTargetKnown() {
        if (Navigation.getNavigationTarget(pageObject.navigationTarget, column.menuLevel) === undefined)
            return false
        return true
    }

    // checks if the need for opening a menu arose
    // see navigation.js for further details
    function navigate() {
        var navigationTarget = Navigation.getNavigationTarget(pageObject.navigationTarget, column.menuLevel)

        if (navigationTarget === undefined)
            return

        var openMenuResult = openMenu(navigationTarget, pageObject.navigationData)
        if (openMenuResult === NavigationConstants.NAVIGATION_IN_PROGRESS)
            return // further processing needed

        if (openMenuResult < 0) // processing error
            console.log("MenuColumn.navigate error. Navigation target: " + navigationTarget + " unknown. Navigation data: " + pageObject.navigationData + ". Error code: " + openMenuResult)

        // resets navigation
        column.pageObject.navigationTarget = 0
        column.pageObject.navigationData = undefined
    }

    // hook to open a menu; receives a string to identify menu to be opened
    // returns 0 if target is managed, 1 if more processing is needed, -1 in
    // case of errors
    // see navigation.js for further details
    function openMenu(navigationTarget, navigationData) {
        return NavigationConstants.NAVIGATION_GENERIC_ERROR
    }

    // helper function to retrieve navigationData absolute index inside a model
    function absoluteIndexInModel(model, navigationData) {
        for (var i = 0; i < model.count; ++i) {
            if (model.getObject(i) === navigationData)
                return i
        }
        return -1
    }

    // The signals captured from the MenuContainer to create/close child or the element
    // itself.
    signal closeItem(int menuLevel)
    signal columnClicked()
    signal loadComponent(int menuLevel, variant component, string title, variant dataModel, variant properties)
    signal destroyed()

    // the page where the element is placed
    property variant pageObject: undefined

    // Signals emitted from the container

    // This signal is emitted from the MenuContainer when the requested child
    // is loaded (the child itself can be retrieved from the homonymous property)
    property Item child: null
    signal childLoaded

    // This signal is emitted from the MenuContainer when the child is destroyed
    signal childDestroyed

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
        NumberAnimation { id: defaultanimation; duration: constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    Behavior on opacity {
        enabled: column.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration; easing.type: Easing.InSine }
    }

    property QtObject dataModel: null

    Component.onDestruction: column.destroyed()
}

