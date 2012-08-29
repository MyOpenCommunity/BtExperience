import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/Systems.js" as Script

Page {
    id: systems
    source: "images/bg2.jpg"

    text: qsTr("systems")
    showSystemsButton: false

    ObjectModel {
        id: systemsModel
        source: myHomeModels.systems
    }

    // TODO: find a way to squash together related subsystems (eg. air
    // conditioning and thermal regulation)
    // Also, we need to add things like messages.

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

                onClicked: Stack.openPage(Script.getTarget(itemObject.id))
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

                onClicked: Stack.openPage(Script.getTarget(itemObject.id))
            }

            model: systemsModel
        }
    }
}
