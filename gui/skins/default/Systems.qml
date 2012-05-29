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
        id: pageTitle
        text: qsTr("Systems")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    CardView {
        ListModel {
            id: systemsModel
            ListElement {
                image: "images/systems/carichi.jpg"
                name: "energy management"
                target: "EnergyManagement.qml"
            }
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

        anchors {
            top: pageTitle.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }

        delegate: PagerDelegate {
            source: image
            label: name

            onClicked: {
                if (target !== "")
                    Stack.openPage(target)
            }
        }

        model: systemsModel
    }
}
