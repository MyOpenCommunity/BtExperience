.pragma library

/**
  * Logic for menu navigation.
  *
  * From a user perspective, menu navigation is already in place. What is
  * requested to implement menu navigation is:
  *     - add the path to the paths variable (_init function in this file)
  *     - (re)implement the openMenu hook in all MenuColumns involved (see AntintrusionSystem.qml for an example)
  *     - call (goTo|push)Page method passing the path to use (see navigate method in PopupPage.qml for an example)
  *
  * When requesting a page to goTo or push, a navigationTarget property is eventually set
  * if menu navigation is desired. This property is set on the
  * SystemPage component and is later used to navigate to the proper menu.
  * The navigationTarget property is passed to the getNavigationTarget function alongside
  * the menuLevel property to retrieve the path element to be used to navigate to.
  * The getNavigationTarget function returns undefined if no menu navigation is
  * needed (so navigation processing ceases immediately) or it returns a string
  * that is passed to the openMenu hook. The openMenu hook must be
  * implemented in the corresponding MenuColumn and must navigate to the
  * desired menu.
  * This call is realized by the navigate function defined in the MenuColumn
  * component that calls the openMenu hook (defined in MenuColumn, too).
  * The call to the navigate function is realized in SystemPage.qml when the
  * loadNextColumn signal is triggered on the current menu.
  * The loadNextColumn signal is defined in MenuContainer component.
  * It is triggered when the MenuContainer completes its construction and it is
  * triggered when the loadComponentFinished signal is triggered (in MenuContainer.js
  * there is a connect call that connects the two signals).
  * The loadComponentFinished signal is defined in MenuColumn.qml and it is
  * triggered in onAnimationRunningChanged when the menu the animation finishes.
  *
  * Summarizing, a request to load a page is sent (with navigationTarget property set).
  * The page is loaded and the root MenuContainer is constructed.
  * At the end of construction, the loadNextColumn signal is triggered.
  * In SystemPage, the corresponding slot calls navigate on current MenuColumn.
  * The navigate function calls the openMenu hook on the current MenuColumn.
  * The redefined hook opens the desired menu.
  * At the end of menu animation, the loadComponentFinished signal is triggered.
  * This signal is connected to the loadNextColumn signal that is triggered on
  * the newly opened menu and a sort of recursive call processing goes on till
  * all menus are opened.
  */


var ALARM_LOG = 1

var _paths = []

function _init(paths) {
    // inits all possible navigation paths
    paths[ALARM_LOG] = ["AlarmLog"]
}

// returns a string indicating where to navigate
// returns undefined if no navigation is needed
function getNavigationTarget(current_path, menuLevel) {
    // init, if needed
    if (_paths.length === 0)
        _init(_paths)

    var result = undefined

    if (current_path > 0) // 0 means no menu navigation
        result = _paths[current_path][menuLevel]

    return result
}

