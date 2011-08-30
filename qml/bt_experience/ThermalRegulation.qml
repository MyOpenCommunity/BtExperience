import QtQuick 1.0
import "Stack.js" as Stack

Page {
    id: page
    source: "systems/termoregolazione.jpg"

    ToolBar {
            id: toolbar
            fontFamily: semiBoldFont.name
            fontSize: 15
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
                font.family: lightFont.name
                anchors.fill: parent
        }
    }

    MenuContainer {
        id: container
        x: 146
        y: 77
        width: 600
        height: 380
        rootElement: "ThermalRegulationLevel1.qml"
        onClosed: Stack.popPage()
    }
}
