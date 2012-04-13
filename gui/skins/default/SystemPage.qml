import QtQuick 1.1
import "js/Stack.js" as Stack
import Components 1.0

Page {
    id: systemPage
    property string text
    property string rootElement
    property alias rootObject: container.rootObject
    property alias currentObject: container.currentObject
    property QtObject names: null

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

    // The spacing between the buttons on the left and the MenuContainer
    property int containerLeftMargin: 20

    MenuContainer {
        id: container
        x: 122 + backButton.width + containerLeftMargin
        y: 63
        width: 893
        height: 530
        rootElement: systemPage.rootElement
        pageObject: systemPage
        onClosed: Stack.popPage()
    }

    Column {
        id: buttonsColumn
        width: backButton.width
        spacing: 10
        anchors.topMargin: container.y + 33
        anchors.top: parent.top
        anchors.leftMargin: container.x - backButton.width - containerLeftMargin
        anchors.left: parent.left

        ButtonBack {
            id: backButton
            onClicked: container.closeLastColumn()
        }

        ButtonSystems {
            onClicked: container.closed()
        }
    }
}

