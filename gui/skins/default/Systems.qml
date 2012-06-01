import QtQuick 1.1
import "js/Stack.js" as Stack
import Components 1.0

Page {
    id: systems
    source: "images/bg2.jpg"

    function pageSkip() {
        if (systemsModel.count === 1) {
            return {"page": systemsModel.get(0).target, "properties": {}}
        }
        return {"page": "", "properties": {}}
    }

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    NavigationBar {
        id: buttonsColumn
        anchors.topMargin: 50
        anchors.top: toolbar.bottom
        anchors.leftMargin: 2
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        systemsButton: false
        text: qsTr("systems")

        onBackClicked: Stack.popPage()
    }

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

    Loader {
        id: viewLoader
        anchors {
            top: toolbar.bottom
            right: parent.right
            rightMargin: 30
            left: buttonsColumn.right
            leftMargin: 30
            bottom: parent.bottom
        }
        sourceComponent: systemsModel.count > 7 ? cardGrid : cardList
    }

    Component {
        id: cardList
        CardView {
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

    Component {
        id: cardGrid

        CardGridView {
            delegate: CardGridDelegate {
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
}
