import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack

Page {
    id: systemPage

    property QtObject rootColumn
    property alias rootObject: container.rootObject
    property alias currentObject: container.currentObject
    property QtObject names: null

    showSystemsButton: true

    // The spacing between the buttons on the left and the MenuContainer
    property int containerLeftMargin: systemPage.width / 100 * 2
    property int navigationTarget: 0 // for menu navigation, see navigation.js for further details
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

    function backButtonClicked() {
        container.closeLastColumn()
    }

    function systemsButtonClicked() {
        Stack.backToSystemOrHome()
    }

    function systemPageClosed() {
        Stack.backToSystemOrHome()
    }

    Pannable {
        id: pannable
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
