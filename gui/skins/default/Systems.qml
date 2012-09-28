import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/Systems.js" as Script
import BtExperience 1.0

Page {
    id: systems
    source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/home.jpg" :
                                                            "images/home/home_dark.jpg"

    text: qsTr("systems")
    showSystemsButton: false

    ObjectModel {
        id: systemsModel
        source: myHomeModels.systems
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
                property variant itemObject: systemsModel.getObject(index)
                source: itemObject.image
                label: itemObject.description

                onClicked: Stack.goToPage(Script.getTarget(itemObject.containerId))
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
                property variant itemObject: systemsModel.getObject(index)
                source: itemObject.image
                label: itemObject.description

                onClicked: Stack.goToPage(Script.getTarget(itemObject.containerId))
            }

            model: systemsModel
        }
    }

    Component.onCompleted: systemsModel.containers = Script.systemsModelContainers(systemsModel)
}
