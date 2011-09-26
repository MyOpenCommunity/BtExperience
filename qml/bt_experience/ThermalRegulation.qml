import QtQuick 1.1
import "Stack.js" as Stack

Page {
    id: page
    source: "systems/termoregolazione.jpg"

    ToolBar {
            id: toolbar
            fontFamily: semiBoldFont.name
            fontSize: 17
            onCustomClicked: Stack.backToHome()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 50
        y: 560
        id: mainText

        Text {
                color: "#ffffff"
                text: "termoregolazione"
                rotation: 270
                font.pixelSize: 60
                font.family: lightFont.name
                anchors.fill: parent
        }
    }

    MenuContainer {
        id: container
        x: 122
        y: 75
        width: 922
        height: 490
        rootElement: "ThermalRegulationItems.qml"
        onClosed: Stack.popPage()
    }
}
