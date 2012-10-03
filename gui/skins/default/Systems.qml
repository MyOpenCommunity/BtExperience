import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
//import Components.Text 1.0
import "js/Stack.js" as Stack
import "js/Systems.js" as Script
import BtExperience 1.0

Page {
    id: systems
    source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/home.jpg" :
                                                            "images/home/home_dark.jpg"

    text: qsTr("systems")

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
        sourceComponent: systemsModel.count >= 3 ? cardPathView : cardList
    }

    Component {
        id: cardPathView

        ControlPathView {
            x0FiveElements: 150
            x0ThreeElements: 250
            y0: 270
            x1: 445
            y1: 250
            x2FiveElements: 740
            x2ThreeElements: 640
            sevenCards: true
            model: systemsModel
            onClicked: Stack.goToPage(Script.getTarget(delegate.containerId))
        }
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

            delegateSpacing: 40
            visibleElements: 2

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
