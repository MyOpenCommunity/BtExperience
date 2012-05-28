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

    ListView {
        id: users
        property int currentPressed: -1
        model: roomsModel.rooms()
        delegate: roomDelegate
        orientation: ListView.Horizontal
        spacing: 2
        clip: true
        height: 300

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
        onFlickStarted: currentPressed = -1
        onMovementEnded: currentPressed = -1

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
                width: delegateBackground.width
                height: delegateBackground.height + delegateShadow.height

                Rectangle {
                    id: textDelegate
                    width: 175
                    height: 20
                    color: Qt.rgba(230, 230, 230)
                    opacity: 0.5
                    Text {
                        text: modelData
                        font.family: regularFont.name
                        font.pixelSize: 15
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: delegateBackground
                    width: 175
                    height: 244
                    anchors.top: textDelegate.bottom
                    color: Qt.rgba(230, 230, 230)
                    opacity: 0.5
                }

                Image {
                    id: imageDelegate
                    width: 169
                    height: 238
                    anchors { bottom: delegateBackground.bottom; bottomMargin: 5 }
                    source: users.selectRoomImage(modelData)
                }

                SvgImage {
                    id: delegateShadow
                    source: "images/home/pager_shadow.svg"
                    anchors {
                        top: delegateBackground.bottom
                        topMargin: 5
                        horizontalCenter: delegateBackground.horizontalCenter
                    }
                }

                SvgImage {
                    id: rectPressed
                    source: "images/common/profilo_p.svg"
                    visible: false
                    anchors.fill: imageDelegate
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: Stack.openPage("Room.qml", {'roomName': modelData})
                    onPressed: itemDelegate.ListView.view.currentPressed = index
                    onReleased: itemDelegate.ListView.view.currentPressed = -1
                }

                states: State {
                    when: itemDelegate.ListView.view.currentPressed === index
                    PropertyChanges {
                        target: rectPressed
                        visible: true
                    }
                }
            }
        }
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


