import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


Page {
    id: mainarea

    property int floorUii

    source: "images/home/home.jpg"
    text: qsTr("rooms")

    MediaModel {
        source: myHomeModels.rooms
        id: roomsModel
        containers: [floorUii]
    }

    ControlPathView {
        visible: roomsModel.count >= 3
        x0FiveElements: 150
        x0ThreeElements: 250
        y0: 180
        x1: 445
        y1: 160
        x2FiveElements: 740
        x2ThreeElements: 640
        model: roomsModel
        anchors {
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            top: toolbar.bottom
            topMargin: 50
            bottom: floorView.top
        }
        pathOffset: model.count === 4 ? -40 : (model.count === 6 ? -40 : 0)
        arrowsMargin: model.count === 4 ? 70 : (model.count === 6 ? 30 : 10)
        onClicked: Stack.goToPage("Room.qml", {'roomName': delegate.description, 'roomUii': delegate.uii, 'floorUii': mainarea.floorUii})
    }

    CardView {
        anchors {
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            top: toolbar.bottom
            bottom: floorView.top
        }
        visible: model.count < 3
        delegate: CardDelegate {
            property variant itemObject: roomsModel.getObject(index)
            source: itemObject.image
            label: itemObject.description

            onClicked: Stack.goToPage("Room.qml", {'roomName': itemObject.description, 'roomUii': itemObject.uii, 'floorUii': mainarea.floorUii})
        }

        delegateSpacing: 40
        visibleElements: 2

        model: roomsModel
    }

    ListView {
        id: floorView
        interactive: false
        orientation: ListView.Horizontal
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 32
        height: 100
        width: 140 * floorsModel.count
        delegate: Image {
            property variant itemObject: floorsModel.getObject(index)

            source: index === floorView.currentIndex ? "images/common/pianoS.png" : "images/common/piano.png"
            UbuntuLightText {
                text: itemObject.description
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: index === floorView.currentIndex === true ? "white" : "black"
            }

            BeepingMouseArea {
                anchors.fill: parent
                onClicked: floorView.currentIndex = index
            }
        }

        onCurrentIndexChanged: {
            mainarea.floorUii = floorsModel.getObject(currentIndex).uii
        }

        MediaModel {
            source: myHomeModels.floors
            id: floorsModel
        }

        model: floorsModel
    }

}


