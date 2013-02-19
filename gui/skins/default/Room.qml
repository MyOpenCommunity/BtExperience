import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0
import Components 1.0
import "js/navigation.js" as Navigation

Page {
    id: page

    property variant room
    property variant names: translations
    property int floorUii

    source: room.image

    function roomsButtonClicked() {
        Stack.backToRoomOrHome()
    }

    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {navigationTarget: Navigation.ROOM_SETTINGS, navigationData: [floorUii, room]})
    }

    text: room.description
    showBackButton: true
    showRoomsButton: true
    showSettingsButton: true

    function backButtonClicked() {
        Stack.backToRoomOrHome()
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
                width: page.width / 100 * 11.3
                height: page.height / 100 * 11.7
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -page.width / 100 * 0.2

                BeepingMouseArea {
                    id: clickMouseArea
                    anchors.fill: parent
                    onPressed: roomView.currentIndex = index
                }

                Rectangle {
                    color: "black"
                    opacity: 0.7
                    anchors.fill: parent
                    visible: clickMouseArea.pressed
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
