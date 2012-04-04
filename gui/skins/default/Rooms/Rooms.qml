import QtQuick 1.1
import ".."
import "../js/Stack.js" as Stack

Page {
    id: mainarea
    source: "../images/home/home.jpg"

    ToolBar {
        id: toolbar
        onHomeClicked: Stack.backToHome()
        fontFamily: semiBoldFont.name
        fontSize: 17
    }
    Text {
        text: qsTr("stanze")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    PathView {
         ListModel {
             id: roomsModel
             ListElement {
                 image: "../images/rooms/studio.png"
                 name: "studio"
             }
             ListElement {
                 image: "../images/rooms/box.png"
                 name: "box"
             }
             ListElement {
                 image: "../images/rooms/cameretta.png"
                 name: "camera ragazzi"
             }
             ListElement {
                 image: "../images/rooms/camera.png"
                 name: "camera genitori"
             }
             ListElement {
                 image: "../images/rooms/bagno.png"
                 name: "bagno zona giorno"
             }
             ListElement {
                 image: "../images/rooms/cucina.png"
                 name: "cucina"
             }
             ListElement {
                 image: "../images/rooms/soggiorno.png"
                 name: "soggiorno"
             }
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
                     source: image
                 }

                 Text {
                     id: textDelegate
                     text: name
                     font.family: regularFont.name
                     font.pixelSize: 22
                     anchors.top: imageDelegate.bottom
                     anchors.topMargin: 10
                     anchors.left: parent.left
                     anchors.right: parent.right
                     horizontalAlignment: Text.AlignHCenter
                 }
//                 Component.onCompleted: {
//                     console.log('icon scale: ' + PathView.iconScale + ' x:' + itemDelegate.x)
//                 }

                 MouseArea {
                     anchors.fill: parent
                     onClicked: Stack.openPage("Rooms/Room.qml")
                 }
             }
         }

         id: users
         model: roomsModel
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
         pathItemCount: 7
         anchors.bottom: parent.bottom
         anchors.bottomMargin: 0
         anchors.top: toolbar.bottom
         anchors.topMargin: 0
         anchors.left: parent.left
         anchors.leftMargin: 0
    }

    ListView {
        orientation: ListView.Horizontal
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 100
        width: 140 * floorModel.count
        delegate: Image {
            source: model.selected === true ? "../images/common/pianoS.png" : "../images/common/piano.png"
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


