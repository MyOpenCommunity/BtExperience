import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0
import Components 1.0

Page {
    id: page

    property variant room
    property variant names: translations
    property int floorUii

    source: room.image

    function roomsButtonClicked() {
        Stack.backToRoom()
    }

    text: room.description
    showBackButton: true
    showRoomsButton: true

    function backButtonClicked() {
        Stack.backToRoom()
    }

    Names {
        id: translations
    }

    MediaModel {
        source: myHomeModels.objectLinks
        id: roomModel
        containers: [room.uii]
        onContainersChanged: page.state = ""
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomsModel
        containers: [floorUii]
    }

    RoomView {
        id: roomCustomView

        anchors {
            left: navigationBar.right
            leftMargin: 20
            right: parent.right
            rightMargin: 20
            top: toolbar.bottom
            bottom: roomView.top
        }
        pageObject: page
        model: roomModel
    }

    ListView {
        id: roomView

        anchors {
            bottom: parent.bottom
            left: navigationBar.right
            right: parent.right
        }
        height: 110
        orientation: ListView.Horizontal
        interactive: false
        currentIndex: findCurrentIndex()
        model: roomsModel
        visible: model.count > 1

        delegate: Image {
            id: listDelegate

            property variant itemObject: roomsModel.getObject(index)

            source: roomView.currentIndex === index ? "images/common/stanzaS.png" : "images/common/stanza.png"

            Image {
                source: itemObject.cardImageCached
                fillMode: Image.PreserveAspectCrop
                clip: true
                width: parent.width - (roomView.currentIndex === index ? 30 : 20)
                height: parent.height - (roomView.currentIndex === index ? 30 : 20)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                BeepingMouseArea {
                    anchors.fill: parent
                    onClicked: roomView.currentIndex = index
                }
            }
        }

        onCurrentIndexChanged: page.room = roomsModel.getObject(currentIndex)
    }

    function findCurrentIndex() {
        for (var i = 0; i < roomsModel.count; ++i)
            if (roomsModel.getObject(i).uii === room.uii)
                    return i;

        return 0;
    }
}
