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

//    CardView {
//        id: users
//        anchors {
//            right: parent.right
//            rightMargin: 30
//            left: parent.left
//            leftMargin: 30
//            top: pageTitle.bottom
//            topMargin: 50
//            bottom: floorView.top
//        }

//        MediaModel {
//            source: myHomeModels.rooms
//            id: roomsModel
//            containers: [floorUii]
//        }


//        model: roomsModel
//        delegate: CardDelegate {
//            source: users.selectRoomImage(itemObject.description)
//            property variant itemObject: roomsModel.getObject(index)
//            label: itemObject.description

//            onClicked: Stack.openPage("Room.qml", {'roomName': itemObject.description, 'roomUii': itemObject.uii, 'floorUii': mainarea.floorUii})
//        }
//        delegateSpacing: 20
//        visibleElements: 4

//        function selectRoomImage(room) {
//            if (room === "living room")
//                return "images/rooms/soggiorno.png"
//            else if (room === "bathroom")
//                return "images/rooms/bagno.png"
//            else if (room === "garage")
//                return "images/rooms/box.png"
//            else if (room === "bedroom")
//                return "images/rooms/camera.png"
//            else if (room === "kitchen")
//                return "images/rooms/cucina.png"
//            console.log("Unknown room, default to studio")
//            return "images/rooms/studio.png"
//        }
//    }

    PathView {
        id: users

        property int currentPressed: -1

        MediaModel {
            source: myHomeModels.rooms
            id: roomsModel
            containers: [floorUii]
        }

        model: roomsModel
        delegate: usersDelegate

        Component {
            id: usersDelegate
            Item {
                id: itemDelegate

                property variant itemObject: roomsModel.getObject(index)

                width: imageDelegate.sourceSize.width
                height: imageDelegate.sourceSize.height + textDelegate.height

                z: PathView.elementZ
                scale: PathView.elementScale

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

                Image {
                    id: imageDelegate
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: itemDelegate.selectRoomImage(itemObject.description)
                }

                UbuntuLightText {
                    id: textDelegate
                    text: itemObject.description
                    font.pixelSize: 22
                    anchors.top: imageDelegate.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8
                    horizontalAlignment: Text.AlignHCenter
                }

                SvgImage {
                    id: rectPressed
                    source: global.guiSettings.skin === 0 ? "images/common/profilo_p.svg" :
                                                            "images/home_dark/home.jpg"
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
                    onClicked: Stack.openPage("Room.qml", {'roomName': itemObject.description, 'roomUii': itemObject.uii, 'floorUii': mainarea.floorUii})
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

        path: Path {
            startX: roomsModel.count < 5 ? 250 : 180; startY: 155
            PathAttribute { name: "elementScale"; value: 0.5 }
            PathAttribute { name: "elementZ"; value: 0.5 }
            PathLine { x: 497; y: 105 }
            PathAttribute { name: "elementScale"; value: 1.1 }
            PathAttribute { name: "elementZ"; value: 1 }
            PathLine { x: roomsModel.count < 5 ? 714 : 784; y: 155 }
            PathAttribute { name: "elementScale"; value: 0.5 }
            PathAttribute { name: "elementZ"; value: 0.5 }
        }

        pathItemCount: roomsModel.count < 5 ? 3 : 5
        highlightRangeMode: PathView.StrictlyEnforceRange
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        onFlickStarted: currentPressed = -1
        onMovementEnded: currentPressed = -1
        anchors {
            right: parent.right
            rightMargin: 30
            left: parent.left
            leftMargin: 30
            top: pageTitle.bottom
            topMargin: 50
            bottom: floorView.top
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


