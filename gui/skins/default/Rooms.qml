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
        text: qsTr("Rooms")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    PathView {
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

        RoomListModel {
            id: roomsModel
        }

        Component {
            id: roomDelegate
            Item {
                id: itemDelegate
                width: imageDelegate.sourceSize.width
                height: imageDelegate.sourceSize.height + textDelegate.height

                z: PathView.z
                scale: PathView.iconScale + 0.1

                Image {
                    id: imageDelegate
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: users.selectRoomImage(modelData)
                }

                Text {
                    id: textDelegate
                    text: modelData
                    font.family: regularFont.name
                    font.pixelSize: 22
                    anchors.top: imageDelegate.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                }

                SvgImage {
                    id: rectPressed
                    source: "images/common/profilo_p.svg"
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

                    onClicked: Stack.openPage("Room.qml", {'roomName': modelData})
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

        id: users
        property int currentPressed: -1
        model: roomsModel.rooms()
        delegate: roomDelegate

        path:  Path {
            startX: 100; startY: 250
            PathAttribute { name: "iconScale"; value: 0.4 }
            PathAttribute { name: "z"; value: 0.1 }
            PathLine { x: 210; y: 250; }
            PathAttribute { name: "iconScale"; value: 0.6 }
            PathLine { x: 420; y: 240; }
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathAttribute { name: "z"; value: 1.0 }
            PathLine { x: 600; y: 253; }
            PathAttribute { name: "iconScale"; value: 0.8 }
            PathLine { x: 800; y: 242; }
            PathAttribute { name: "z"; value: 0.1 }
            PathAttribute { name: "iconScale"; value: 0.45 }
            PathLine { x: 950; y: 250; }
        }
        width: 950
        pathItemCount: count
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: toolbar.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        onFlickStarted: currentPressed = -1
        onMovementEnded: currentPressed = -1
    }

    ListView {
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


