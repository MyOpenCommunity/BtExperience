import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack

Page {
    id: systemPage
    property string text
    property QtObject rootColumn
    property alias rootObject: container.rootObject
    property alias currentObject: container.currentObject
    property QtObject names: null

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    // The spacing between the buttons on the left and the MenuContainer
    property int containerLeftMargin: 0

    Pannable {
        id: pannable
        anchors.left: navbar.right
        anchors.leftMargin: parent.width / 100 * 1
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        MenuContainer {
            x: 0
            y: parent.childOffset
            width: parent.width
            height: parent.height
            id: container
            rootColumn: systemPage.rootColumn
            pageObject: systemPage
            onClosed: Stack.popPage()
        }
    }

    Constants {
        id: constants
    }

    NavigationBar {
        id: navbar
        anchors.topMargin: constants.navbarTopMargin
        anchors.top: toolbar.bottom
        anchors.leftMargin: 2
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        text: systemPage.text

        onBackClicked: container.closeLastColumn()
        onSystemsClicked: container.closed()
    }
}

