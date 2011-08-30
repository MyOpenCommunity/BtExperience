import QtQuick 1.0
import "Stack.js" as Stack

Page {
    id: systems
    source: "systems/illuminazione.jpg"

    ToolBar {
            id: toolbar
            fontFamily: semiBoldFont.name
            fontSize: 15
            onCustomClicked: Stack.backToHome()
    }

 Rectangle {
     anchors.left: parent.left
     anchors.leftMargin: 50
     y: 390
     id: mainText

     Text {
             color: "#ffffff"
             text: "illuminazione"
             rotation: 270
             font.pixelSize: 54
             font.family: lightFont.name
             anchors.fill: parent
     }
 }

 MenuContainer {
     id: menucontainer1
     x: 121
     y: 49
     width: 658
     height: 412
     rootElement: "LightingItems.qml"
     onClosed: Stack.popPage()
 }

}
