import QtQuick 1.1
import "js/Stack.js" as Stack
import Components 1.0
import BtObjects 1.0

Page {
    id: mainarea
    source: "images/home/home.jpg"

    ToolBar {
        id: toolbar
        onHomeClicked: Stack.backToHome()
        fontFamily: semiBoldFont.name
        fontSize: 17
    }
    Text {
        id: pageTitle
        text: qsTr("Rooms")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    CardView {
        id: users
        anchors {
            right: parent.right
            left: parent.left
            top: pageTitle.bottom
            bottom: floorView.top
        }

        RoomListModel {
            id: roomsModel
        }

        model: roomsModel.rooms()
        delegate: PagerDelegate {
            source: users.selectRoomImage(modelData)
            label: modelData

            onClicked: Stack.openPage("Room.qml", {'roomName': modelData})
        }

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
    }

    ListView {
        id: floorView
        orientation: ListView.Horizontal
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 100
        width: 140 * floorModel.count
        delegate: Image {
            source: model.selected === true ? "images/common/pianoS.png" : "images/common/piano.png"
            Text {
                text: model.name
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: model.selected === true ? "white" : "black"
            }
        }

        model: floorModel
        ListModel {
            id: floorModel
            ListElement {
                name: "piano terra"
                selected: true
            }
            ListElement {
                name: "mansarda"
                selected: false
            }
        }
    }

}


