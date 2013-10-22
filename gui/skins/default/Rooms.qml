import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief A page showing all rooms.

  A page to show all rooms grouped by floor. The user may select one room and
  open the related page.
  */
Page {
    id: mainarea

    source : homeProperties.homeBgImage
    text: qsTr("rooms")

    MediaModel {
        source: myHomeModels.floors
        id: floorsModel
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomsModel
        containers: [floorsModel.getObject(bottomFloorsView.selectedIndex).uii]
    }

    // Use a loader to destroy and rebuild ControlPathView.
    // If we re-use a single ControlPathView, it's really hard to get the offset
    // value right because:
    // - we must ensure that the offset is valid when switching from a floor
    //   with many rooms to a floor with few rooms (bug #22348)
    // - we must not show the offset animation when switching model, which is
    //   hard because we depend on many different signals
    // - resetting the offset on model reset leads to bugs in other places (bug
    //   #24111)
    Loader {
        id: loader
        visible: roomsModel.count >= 3
        sourceComponent: pathViewComponent
        anchors {
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            top: toolbar.bottom
            topMargin: 50
            bottom: bottomFloorsView.top
        }
    }

    Component {
        id: pathViewComponent
        ControlPathView {
            x0FiveElements: 150
            x0ThreeElements: 250
            y0: 180
            x1: 445
            y1: 160
            x2FiveElements: 740
            x2ThreeElements: 640
            pathviewId: privateProps.floorUii()
            model: roomsModel
            pathOffset: model.count === 4 ? -40 : (model.count === 6 ? -40 : 0)
            arrowsMargin: model.count === 4 ? 70 : (model.count === 6 ? 30 : 10)
            onClicked: Stack.goToPage("Room.qml", {'room': delegate, 'floorUii': privateProps.floorUii()})
        }
    }

    Connections {
        target: roomsModel
        onModelAboutToBeReset: {
            loader.sourceComponent = undefined
        }
        onModelReset: {
            loader.sourceComponent = pathViewComponent
        }
    }

    CardView {
        anchors {
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            top: toolbar.bottom
            bottom: bottomFloorsView.top
        }
        visible: model.count < 3
        delegate: CardDelegate {
            property variant itemObject: roomsModel.getObject(index)
            source: itemObject.cardImageCached
            label: itemObject.description

            onClicked: Stack.goToPage("Room.qml", {'room': itemObject, 'floorUii': privateProps.floorUii()})
        }

        delegateSpacing: 40
        visibleElements: 2

        model: roomsModel
    }

    HorizontalView {
        id: bottomFloorsView
        anchors {
            left: navigationBar.right
            leftMargin: parent.width / 100
            right: parent.right
            rightMargin: parent.width / 100
            bottom: parent.bottom
        }
        height: 110
        model: floorsModel
        selectedIndex: global.floorIndex
        delegate: Image {
            property variant itemObject: floorsModel.getObject(index)

            source: index === bottomFloorsView.selectedIndex ? "images/common/pianoS.png" : "images/common/piano.png"
            UbuntuLightText {
                text: itemObject.description
                anchors {
                    // the image is a png and it has borders, so I'm using
                    // fixed values here.
                    left: parent.left
                    leftMargin: 14
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                color: index === bottomFloorsView.selectedIndex ? "white" : "black"
                elide: Text.ElideRight
            }

            BeepingMouseArea {
                anchors.fill: parent
                onClicked: global.floorIndex = index
            }
        }
    }

    QtObject {
        id: privateProps

        function floorUii() {
            return floorsModel.getObject(bottomFloorsView.selectedIndex).uii
        }
    }
}


