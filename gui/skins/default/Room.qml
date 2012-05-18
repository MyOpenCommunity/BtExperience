import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0
import Components 1.0

Page {
    id: page
    source: "images/imgsfondo_sfumato.png"
    property variant names: translations
    property string roomName

    Names {
        id: translations
    }

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    NavigationBar {
        id: systemsButton
        backButton: false
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.top: toolbar.bottom
        anchors.topMargin: 30

        onSystemsClicked: Stack.popPage()
    }

    RoomListModel {
        id: roomModel
        room: roomName
        onRoomChanged: page.state = ""
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
            left: systemsButton.right
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
        anchors.left: parent.left
        width: parent.width
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

        // TODO: this is needed because the model is a simple stringlist;
        // to be fixed with a proper model.
        property int currentIndex: -1

        orientation: ListView.Horizontal
        delegate: Image {
            id: listDelegate
            source: ListView.view.currentIndex === index ? "images/common/stanzaS.png" : "images/common/stanza.png"
            Image {
                source: listDelegate.ListView.view.selectRoomImage(modelData)
                fillMode: Image.PreserveAspectCrop
                clip: true
                width: parent.width - (listDelegate.ListView.view.currentIndex === index ? 30 : 20)
                height: parent.height - (listDelegate.ListView.view.currentIndex === index ? 30 : 20)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked on room: " + modelData)
                        roomModel.room = modelData
                        listDelegate.ListView.view.currentIndex = index
                    }
                }
            }
        }

        model: roomModel.rooms()
    }

    function closeCurrentMenu() {
        page.state = ""
        roomCustomView.closeMenu()
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
