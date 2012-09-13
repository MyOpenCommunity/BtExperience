import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: mainarea
    source: "images/home/home.jpg"
    property int floorUii

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onHomeClicked: Stack.backToHome()
    }

    UbuntuLightText {
        id: pageTitle
        text: qsTr("Rooms")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    ObjectModel {
        id: roomsModel
        source: myHomeModels.rooms
    }

    ControlPathView {
        visible: roomsModel.count >= 3
        x0FiveElements: 180
        x0ThreeElements: 250
        y0: 155
        x1: 497
        y1: 105
        x2FiveElements: 784
        x2ThreeElements: 714
        model: roomsModel
        anchors {
            right: parent.right
            rightMargin: 30
            left: parent.left
            leftMargin: 30
            top: pageTitle.bottom
            topMargin: 50
            bottom: floorView.top
        }
        onClicked: Stack.openPage("Room.qml", {'roomName': delegate.description, 'roomUii': delegate.uii, 'floorUii': mainarea.floorUii})
    }

    Item { // needed to properly center the CardView
        anchors {
            right: parent.right
            rightMargin: 30
            left: parent.left
            leftMargin: 30
            top: pageTitle.bottom
            topMargin: 50
            bottom: floorView.top
        }
        CardView {
            visible: model.count < 3
            delegate: CardDelegate {
                property variant itemObject: roomsModel.getObject(index)
                source: itemObject.image
                label: itemObject.description

                onClicked: Stack.openPage("Room.qml", {'roomName': itemObject.description, 'roomUii': itemObject.uii, 'floorUii': mainarea.floorUii})
            }

            delegateSpacing: 40
            visibleElements: 2

            model: roomsModel
            anchors.centerIn: parent
        }
    }

    ListView {
        id: floorView
        orientation: ListView.Horizontal
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
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

            MouseArea {
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


