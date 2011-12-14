import QtQuick 1.1
import "Stack.js" as Stack

Page {
    id: systems
    source: "images/illuminazione.jpg"

    ToolBar {
            id: toolbar
            fontFamily: semiBoldFont.name
            fontSize: 17
            onHomeClicked: Stack.backToHome()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 50
        y: 450
        id: mainText

        Text {
             color: "#ffffff"
             text: "illuminazione"
             rotation: 270
             font.pixelSize: 60
             font.family: lightFont.name
             anchors.fill: parent
        }
    }

    MenuContainer {
     id: menucontainer1
     x: 122
     y: 75
     width: 828
     height: 503
     rootElement: "LightingItems.qml"
     onClosed: Stack.popPage()
    }
}

