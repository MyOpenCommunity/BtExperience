import QtQuick 1.1
import "js/Stack.js" as Stack
import Components 1.0

Page {
    id: systems
    source: "images/bg2.jpg"

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    Text {
        text: qsTr("Systems")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    PathView {
        ListModel {
            id: systemsModel
            ListElement {
                image: "images/systems/carichi.jpg"
                name: "antintrusion"
                target: "Antintrusion.qml"
            }
            ListElement {
                image: "images/systems/scenari.jpg"
                name: "scenari"
                target: "Scenarios.qml"
            }
            ListElement {
                image: "images/systems/termo.jpg"
                name: "temperature control"
                target: "ThermalRegulation.qml"
            }
            ListElement {
                image: "images/systems/illuminazione.jpg"
                name: "lighting"
                target: "Lighting.qml"
            }
            ListElement {
                image: "images/systems/diffusione-sonora.jpg"
                name: "sound diffusion system"
                target: "SoundDiffusion.qml"
            }
            ListElement {
                image: "images/systems/movimentazione.jpg"
                name: "automation"
                target: ""
            }
            ListElement {
                image: "images/systems/messaggi.jpg"
                name: "message"
                target: ""
            }
            ListElement {
                image: "images/systems/videocitofonia.jpg"
                name: "video door entry"
                target: "VideoDoorEntry.qml"
            }
        }

        Component {
            id: systemsDelegate
            Item {
                id: itemDelegate
                width: imageDelegate.sourceSize.width
                height: imageDelegate.sourceSize.height + textDelegate.height

                z: PathView.z
                scale: PathView.iconScale + 0.1

                Image {
                    id: imageDelegate
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: image
                }

                Text {
                    id: textDelegate
                    text: name
                    anchors.leftMargin: 0
                    verticalAlignment: Text.AlignTop
                    font.family: regularFont.name
                    font.pixelSize: 22
                    anchors.top: imageDelegate.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill:  parent
                    onClicked: {
                        if (target !== "")
                            Stack.openPage(target)
                    }
                }
            }
        }

        id: users
        model: systemsModel
        delegate: systemsDelegate

        path:  Path {
            startX: 100; startY: 250
            PathAttribute { name: "iconScale"; value: 0.4 }
            PathAttribute { name: "z"; value: 0.1 }
            PathLine { x: 210; y: 250; }
            PathAttribute { name: "iconScale"; value: 0.6 }
            PathLine { x: 420; y: 240; }
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathAttribute { name: "z"; value: 1.0 }
            PathLine { x: 600; y: 253; }
            PathAttribute { name: "iconScale"; value: 0.8 }
            PathLine { x: 800; y: 242; }
            PathAttribute { name: "z"; value: 0.1 }
            PathAttribute { name: "iconScale"; value: 0.45 }
            PathLine { x: 950; y: 250; }
        }
        width: 620
        pathItemCount:7
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: toolbar.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
    }
}
