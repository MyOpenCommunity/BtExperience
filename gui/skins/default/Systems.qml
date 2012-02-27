import QtQuick 1.1
import "Stack.js" as Stack

Page {
    id: systems
    source: "images/bg2.jpg"

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    PathView {
        ListModel {
                id: systemsModel
                ListElement {
                    image: "images/antintrusion.jpg"
                    name: "antintrusione"
                    target: "Antintrusion.qml"
                }
                ListElement {
                    image: "images/scenari.jpg"
                    name: "scenari"
                    target: ""
                }
                ListElement {
                    image: "images/termoregolazione.jpg"
                    name: "termoregolazione"
                    target: "ThermalRegulation.qml"
                }
                ListElement {
                    image: "images/illuminazione.jpg"
                    name: "illuminazione"
                    target: "Lighting.qml"
                }
                ListElement {
                    image: "images/sound_diffusion.jpg"
                    name: "diffusione sonora"
                    target: "SoundDiffusion.qml"
                }
            }


        Component {
                id: systemsDelegate
                Image {
                    scale: PathView.iconScale
                    z: PathView.z
                    Rectangle {
                        id: systemBox
                        width: 65
                        anchors.left: parent.left
                        anchors.leftMargin: -1
                        anchors.top: parent.top
                        anchors.topMargin: -1
                        anchors.bottom: parent.bottom
                        opacity: 0.4
                        color: "#000000"
                    }
                    Item {
                        Text {
                            opacity: 1
                            color: "#ffffff"
                            rotation: 270
                            text: name
                            font.bold: false
                            font.pixelSize: 22
                            anchors.fill: parent
                        }
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.bottomMargin: 20
                        anchors.leftMargin: 10
                    }
                    source: image
                    smooth: true
                    width: 575
                    height: 360
                    transform: Rotation { origin.x: 30; origin.y: 30; axis { x: 0; y: 1; z: 0 } angle: 30 }

                    MouseArea {
                        anchors.fill:  parent
                        onClicked: {
                            if (target !== "")
                                  Stack.openPage(target)
                        }
                    }
                }
        }

        model: systemsModel
        delegate: systemsDelegate
        path:  Path {
           startX: 300; startY: 100
           PathAttribute { name: "iconScale"; value: 0.6 }
           PathAttribute { name: "z"; value: 0.0 }
           PathLine { x: 600; y: 240 }
           PathAttribute { name: "iconScale"; value: 1.0 }
           PathAttribute { name: "z"; value: 1.0 }
        }

        width: 480
        height: 300
        x: 100
        y: 100
    }

     Text {
         id: text1
         x: 50
         y: 480
         color: "#ffffff"
         text: "SISTEMI"
         font.pixelSize: 100
     }
}
