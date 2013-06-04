import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief A base page for system pages.

  This is the base page for system pages. A system page shows a system or function.
  This page contains a menu to navigate through all features of a particular
  system.

  This page implements the navigation logic to navigate to a particular page.

  \sa MenuContainer
  */
Page {
    id: systemPage

    property alias rootColumn: container.rootColumn
    property alias rootData: container.rootData
    property alias rootObject: container.rootObject
    property alias currentObject: container.currentObject
    property QtObject names: null
    property QtObject systemNames: SystemsNames {}

    showSystemsButton: true

    // The spacing between the buttons on the left and the MenuContainer
    property int containerLeftMargin: systemPage.width / 100 * 2
    /** the target we want to navigate to if any */
    property int navigationTarget: 0 // for menu navigation, see navigation.js for further details
    /** data needed for navigation if any */
    property variant navigationData: undefined // for menu navigation, see navigation.js for further details

    onNavigationTargetChanged: {
        if (navigationTarget === 0)
            return

        var item = systemPage.rootObject

        if (item === undefined)
            return

        var itemChild = item.child

        while (itemChild && itemChild.isTargetKnown()) {
            item = itemChild
            itemChild = item.child
        }

        item.navigate()
    }

    /**
      Called when back button on navigation bar is clicked.
      Closes last menu column.
      */
    function backButtonClicked() {
        container.closeLastColumn()
    }

    /**
      Called when system button on navigation bar is clicked.
      Navigates back to system page.
      */
    function systemsButtonClicked() {
        Stack.backToSystemOrHome()
    }

    /**
      Hook called when MenuContainer is closed.
      Default implementation navigates back to system page.
      */
    function systemPageClosed() {
        Stack.backToSystemOrHome()
    }

    Pannable {
        id: pannable

        z: 1
        anchors.left: navigationBar.right
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        MenuContainer {
            x: containerLeftMargin
            y: parent.childOffset
            width: parent.width
            height: parent.height
            id: container
            rootColumn: systemPage.rootColumn
            pageObject: systemPage
            onClosed: systemPage.systemPageClosed()
            onLoadNextColumn: currentObject.navigate() // see navigation.js for further details
        }
    }
}
