import QtQuick 1.1
import "Stack.js" as Stack

Page {
    id: systemPage
    property string text
    property string rootElement
    property alias rootObject: container.rootObject
    property alias currentObject: container.currentObject
    property QtObject names: undefined

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    Text {
        id: mainText
        color: "#ffffff"
        text: systemPage.text
        transformOrigin: Item.BottomLeft
        rotation: 270
        font.pixelSize: 54
//        font.pixelSize: 60
//        font.family: lightFont.name
        y: width + 20  // width and height are reversed because the text is rotated.
        x: height + 20
    }

    MenuContainer {
        id: container
        x: 122
        y: 75
        width: 893
        height: 503
        rootElement: systemPage.rootElement
        pageObject: systemPage
        onClosed: Stack.popPage()
    }
}

