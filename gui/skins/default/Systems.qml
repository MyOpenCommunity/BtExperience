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

    text: qsTr("systems")
    showSystemsButton: false

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
            target: "Automation.qml"
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
            left: navigationBar.right
            leftMargin: 30
            bottom: parent.bottom
        }
        // To switch between CardView and CardGridView:
        // systemsModel.count > 7 ? cardGrid : cardList
        //
        // I'm leaving the CardGridView below just in case we want to enable
        // it again.
        sourceComponent: cardList
    }

    Component {
        id: cardList
        CardView {
            delegate: CardDelegate {
                property variant itemObject: systemsModel.get(index)
                source: itemObject.image
                label: itemObject.name

                onClicked: {
                    if (itemObject.target !== "")
                        Stack.openPage(itemObject.target)
                }
            }

            delegateSpacing: 20
            visibleElements: 4

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
