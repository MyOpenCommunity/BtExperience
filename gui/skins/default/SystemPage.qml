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

    // TODO: this is the text which is on the left. Now we have navigation
    // buttons over there, so I'm removing it.
    // What should we do about it?
//    Text {
//        id: mainText
//        color: "#ffffff"
//        text: systemPage.text
//        transformOrigin: Item.BottomLeft
//        rotation: 270
//        font.pixelSize: 54
////        font.pixelSize: 60
////        font.family: lightFont.name
//        y: width + 20  // width and height are reversed because the text is rotated.
//        x: height + 20
//    }

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

        onBackClicked: container.closeLastColumn()
        onSystemsClicked: container.closed()
    }
}

