import QtQuick 1.1
import "Stack.js" as Stack

Page {
    id: systems
    source: "bg2.jpg"

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 15
        onCustomClicked: Stack.backToHome()
    }

    PathView {
        ListModel {
                id: systemsModel
                ListElement {
                    image: "systems/automazione.jpg"
                    name: "automazione"
                    target: ""
                }
                ListElement {
                    image: "systems/scenari.jpg"
                    name: "scenari"
                    target: ""
                }
                ListElement {
                    image: "systems/termoregolazione.jpg"
                    name: "termoregolazione"
                    target: "ThermalRegulation.qml"
                }
                ListElement {
                    image: "systems/illuminazione.jpg"
                    name: "illuminazione"
                    target: "Lighting.qml"
                }
            }


        Component {
                id: systemsDelegate
                Image {
                    scale: PathView.iconScale
                    z: PathView.z
                    Rectangle {
                        id: systemBox
                        width: 50
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
                            font.pixelSize: 20
                            anchors.fill: parent
                        }
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.bottomMargin: 20
                        anchors.leftMargin: 10
                    }
                    source: image
                    smooth: true
                    width: 450
                    height: 300
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
         x: 36
         y: 356
         color: "#ffffff"
         text: "SISTEMI"
         font.pixelSize: 80
     }
}
