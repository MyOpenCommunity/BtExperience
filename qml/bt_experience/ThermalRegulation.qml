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

    ItemContainer {
        id: container
        x: 146
        y: 77
        width: 600
        height: 380
        Component.onCompleted: {
            level1.source = "ThermalRegulationLevel1.qml"
            addItem(level1, 1)
        }

        onClosed: Stack.popPage()

        Loader {
            id: level1
            onLoaded: item.loadComponent.connect(loadComponent)
            function loadComponent(fileName) {
                console.log("Livello 1 Richiede di caricare: "+ fileName)
                level2.source = fileName
                container.addItem(level2, 2)
            }
        }

        Loader {
            id: level2
            onLoaded: item.loadComponent.connect(loadComponent)
            function loadComponent(fileName) {
                console.log("Livello 2 Richiede di caricare: "+ fileName)
            }

        }
    }



}
