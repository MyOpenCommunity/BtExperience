import QtQuick 1.0
import "Stack.js" as Stack

Page {
    id: page
    source: "systems/termoregolazione.jpg"

    FontLoader { id: localFont; source: "MyriadPro-Light.otf" }
    ToolBar {
            id: toolbar
            onCustomClicked: Stack.backToHome()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 50
        y: 465
        id: mainText

        Text {
                color: "#ffffff"
                text: "termoregolazione"
                rotation: 270
                font.pixelSize: 54
                font.family: localFont.name
                anchors.fill: parent
        }
    }

    ButtonBack {
        id: backButton
        y: 80
        anchors.left: mainText.right
        anchors.leftMargin: 105
        onClicked: Stack.popPage()
    }
}
