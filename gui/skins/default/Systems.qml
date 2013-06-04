import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/Systems.js" as Script


/**
  \ingroup Core

  \brief The entry page for all systems.
  */
Page {
    id: systems

    source : homeProperties.homeBgImage
    text: qsTr("functions")

    ObjectModel {
        id: systemsModel
        source: myHomeModels.systems
    }

    SystemsNames {
        id: names
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
            pathviewId: 3
            model: systemsModel
            pathOffset: model.count === 4 ? -40 : (model.count === 6 ? -40 : 0)
            arrowsMargin: model.count === 4 ? 70 : (model.count === 6 ? 30 : 10)
            onClicked: Stack.goToPage(Script.getTarget(delegate.containerId))
        }
    }

    Component {
        id: cardList
        CardView {
            delegate: CardDelegate {
                property variant itemObject: systemsModel.getObject(index)
                source: itemObject.cardImageCached
                label: itemObject.description

                onClicked: Stack.goToPage(Script.getTarget(itemObject.containerId))
            }

            delegateSpacing: 40
            visibleElements: 2

            model: systemsModel
        }
    }

    Component.onCompleted: {
        systemsModel.containers = Script.systemsModelContainers(systemsModel)
        for (var i = 0; i < systemsModel.count; ++i) {
            var itemObject = systemsModel.getObject(i)
            itemObject.description = names.get(itemObject.containerId)
        }
    }
}
