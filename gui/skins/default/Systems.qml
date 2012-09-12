import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
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
        sourceComponent: cardPathView
    }

    Component {
        id: cardPathView
        PathView {
            id: cardView

            property int currentPressed: -1

            model: systemsModel
            delegate: systemsDelegate

            Component {
                id: systemsDelegate
                Item {
                    id: itemDelegate

                    property variant itemObject: systemsModel.getObject(index)

                    width: imageDelegate.sourceSize.width
                    height: imageDelegate.sourceSize.height + textDelegate.height

                    z: PathView.elementZ
                    scale: PathView.elementScale

                    Image {
                        id: imageDelegate
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        source: itemObject.image
                    }

                    UbuntuLightText {
                        id: textDelegate
                        text: itemObject.description
                        font.pixelSize: 22
                        anchors.top: imageDelegate.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 8
                        horizontalAlignment: Text.AlignHCenter
                    }

                    SvgImage {
                        id: rectPressed
                        source: global.guiSettings.skin === 0 ? "images/common/profilo_p.svg" :
                                                                "images/home_dark/home.jpg"
                        visible: false
                        anchors {
                            centerIn: imageDelegate
                            fill: imageDelegate
                        }
                        width: imageDelegate.width
                        height: imageDelegate.height
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Stack.openPage(Script.getTarget(itemObject.containerId))
                        onPressed: itemDelegate.PathView.view.currentPressed = index
                        onReleased: itemDelegate.PathView.view.currentPressed = -1
                    }

                    states: State {
                        when: itemDelegate.PathView.view.currentPressed === index
                        PropertyChanges {
                            target: rectPressed
                            visible: true
                        }
                    }
                }
            }

            path: Path {
                startX: systemsModel.count < 5 ? 230 : 150; startY: cardView.height / 2 + 50
                PathAttribute { name: "elementScale"; value: 0.5 }
                PathAttribute { name: "elementZ"; value: 0.5 }
                PathLine { x: cardView.width / 2; y: cardView.height / 2 }
                PathAttribute { name: "elementScale"; value: 1.1 }
                PathAttribute { name: "elementZ"; value: 1 }
                PathLine { x: systemsModel.count < 5 ? cardView.width - 230 : cardView.width - 150; y: cardView.height / 2 + 50 }
                PathAttribute { name: "elementScale"; value: 0.5 }
                PathAttribute { name: "elementZ"; value: 0.5 }
            }

            pathItemCount: systemsModel.count < 5 ? 3 : 5
            highlightRangeMode: PathView.StrictlyEnforceRange
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            onFlickStarted: currentPressed = -1
            onMovementEnded: currentPressed = -1
        }
    }

    Component {
        id: cardList
        CardView {
            delegate: CardDelegate {
                property variant itemObject: systemsModel.getObject(index)
                source: itemObject.image
                label: itemObject.description

                onClicked: Stack.openPage(Script.getTarget(itemObject.containerId))
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

                onClicked: Stack.openPage(Script.getTarget(itemObject.containerId))
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
