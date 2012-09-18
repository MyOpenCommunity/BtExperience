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

                onClicked: Stack.pushPage(Script.getTarget(itemObject.containerId))
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

                onClicked: Stack.pushPage(Script.getTarget(itemObject.containerId))
            }

            model: systemsModel
        }
    }

    // TODO: add messages system
    Component.onCompleted: {
        var containers = {}
        var objKeys = function (obj) {
            var keys = [];

            for(var key in obj)
                if(obj.hasOwnProperty(key))
                    keys.push(key);

            return keys;
        }

        for (var i = 0; i < systemsModel.count; ++i) {
            var obj = systemsModel.getObject(i)
            // Squash together similar systems. Since they may have different
            // images and descriptions, we need to give a priority in case there
            // are multiple items.
            //
            // These are the items in order of priority as implemented right now:
            //  * Thermal regulation - Air conditioning
            //  * Energy data - Load control - Supervision
            switch (obj.containerId) {
            case Container.IdThermalRegulation:
            {
                delete containers[Container.IdAirConditioning]
                containers[Container.IdThermalRegulation] = undefined
                break
            }

            case Container.IdAirConditioning:
            {
                if (!(Container.IdThermalRegulation in containers))
                    containers[Container.IdAirConditioning] = undefined
                break
            }

            case Container.IdEnergyData:
            {
                delete containers[Container.IdSupervision]
                delete containers[Container.IdLoadControl]
                containers[Container.IdEnergyData] = undefined
                break
            }

            case Container.IdLoadControl:
            {
                if (!(Container.IdEnergyData in containers)) {
                    delete containers[Container.IdSupervision]
                    containers[Container.IdLoadControl] = undefined
                }

                break
            }

            case Container.IdSupervision:
            {
                if (!(Container.IdEnergyData in containers || Container.IdLoadControl in containers)) {
                    containers[Container.IdSupervision] = undefined
                }
                break
            }

            default:
                containers[obj.containerId] = undefined
            }
        }
        systemsModel.containers = objKeys(containers)
    }
}
