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

    function backButtonClicked() {
        container.closeLastColumn()
    }

    function systemsButtonClicked() {
        Stack.backToSystemOrHome()
    }

    function closeAll() {
        container.closeAll()
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
        }
    }
}

