import QtQuick 1.1
import "js/Stack.js" as Stack
import Components 1.0

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
        x: 122 + buttonsColumn.width + containerLeftMargin
        y: 63
        width: 893 - buttonsColumn.width - containerLeftMargin
        height: 530

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

    NavigationBar {
        id: buttonsColumn
        anchors.topMargin: pannable.y + 33
        anchors.top: parent.top
        anchors.leftMargin: 2
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: systemPage.text

        onBackClicked: container.closeLastColumn()
        onSystemsClicked: container.closed()
    }
}

