import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0
import Components 1.0

Page {
    id: page
    source: "images/imgsfondo_sfumato.png"
    property variant names: translations
    property string roomName
    property int roomUii
    property int floorUii

    function systemsButtonClicked() {
        Stack.popPage()
    }

    text: roomName
    showBackButton: false
    showSystemsButton: true

    Names {
        id: translations
    }

    MediaModel {
        source: myHomeModels.objectLinks
        id: roomModel
        containers: [roomUii]
        onContainersChanged: page.state = ""
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomsModel
        containers: [floorUii]
    }

    MouseArea {
        id: outerClickableArea
        visible: false
        anchors {
            left: parent.left
            right: parent.right
            top: toolbar.bottom
            bottom: roomView.top
        }

        onClicked: page.closeCurrentMenu()
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
        onMenuOpened: page.state = "menuSelected"
        onMenuClosed: page.state = ""
    }

    ListView {
        id: roomView
        anchors.bottom: parent.bottom
        anchors.left: navigationBar.right
        anchors.right: parent.right
        height: 110

        function selectRoomImage(room) {
            if (room === "living room")
                return "images/rooms/soggiorno.png"
            else if (room === "bathroom")
                return "images/rooms/bagno.png"
            else if (room === "garage")
                return "images/rooms/box.png"
            else if (room === "bedroom")
                return "images/rooms/camera.png"
            else if (room === "kitchen")
                return "images/rooms/cucina.png"
            console.log("Unknown room, default to studio")
            return "images/rooms/studio.png"
        }

        orientation: ListView.Horizontal
        interactive: false
        delegate: Image {
            property variant itemObject: roomsModel.getObject(index)
            id: listDelegate
            source: roomView.currentIndex === index ? "images/common/stanzaS.png" : "images/common/stanza.png"
            Image {
                source: roomView.selectRoomImage(listDelegate.itemObject.description)
                fillMode: Image.PreserveAspectCrop
                clip: true
                width: parent.width - (roomView.currentIndex === index ? 30 : 20)
                height: parent.height - (roomView.currentIndex === index ? 30 : 20)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked on room: " + listDelegate.itemObject.description)
                        roomView.currentIndex = index
                        roomName = listDelegate.itemObject.description
                    }
                }
            }
        }

        onCurrentIndexChanged: {
            page.roomUii = roomsModel.getObject(currentIndex).uii
        }

        currentIndex: findCurrentIndex()
        model: roomsModel
    }

    function closeCurrentMenu() {
        page.state = ""
        roomCustomView.closeMenu()
    }

    function findCurrentIndex() {
        for (var i = 0; i < roomsModel.count; ++i)
            if (roomsModel.getObject(i).uii == roomUii)
                    return i;

        return 0;
    }

    states: [
        State {
            name: "menuSelected"
            PropertyChanges {
                target: outerClickableArea
                visible: true
            }
        }
    ]
}
