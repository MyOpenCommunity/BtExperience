import QtQuick 1.1
import "Stack.js" as Stack

Page {
id: mainarea
source: "home.jpg"

    ToolBar {
        id: toolbar
        onExitClicked: console.log("exit")
        fontFamily: semiBoldFont.name
        fontSize: 17
    }

    ListView {
         ListModel {
                 id: favouritesModel
                 ListElement {
                         thumb: "fav1.png"
                 }
                 ListElement {
                         thumb: "fav2.png"
                 }
                 ListElement {
                         thumb: "fav3.png"
                 }
                 ListElement {
                         thumb: "fav4.png"
                 }
                 ListElement {
                         thumb: "fav5.png"
                 }
                 ListElement {
                         thumb: "fav6.png"
                 }
         }

         Component {
                 id: favouritesDelegate
                 Item {
                         width: 170
                         height: 130
                         Image {
                             id: favouritesImage
                             source: thumb
                             width: 150
                             height: 100
                             anchors.horizontalCenter: parent.horizontalCenter
                             anchors.verticalCenter: parent.verticalCenter
                             z: 1
                         }
                         Rectangle {
                             id: shadow
                             gradient: Gradient {
                                 GradientStop { position: 0.0; color: "#214045" }
                                 GradientStop { position: 1.0; color: "#8ca8b4" }
                            }

                             opacity: 0.5
                             width: favouritesImage.width + 10
                             height: favouritesImage.height
                             x: favouritesImage.x
                             y: favouritesImage.y
                             transform: Translate { y: -5; x: -5 }
                         }
                 }
         }

         id: favourites
         x: 0
         model: favouritesModel
         delegate: favouritesDelegate
         orientation: ListView.Horizontal
         y: 372
         width: 1024
         height: 138
         anchors.right: parent.right
         anchors.rightMargin: 0
         anchors.left: parent.left
         anchors.leftMargin: 0
         anchors.bottom: parent.bottom
         anchors.bottomMargin: 0
    }

    PathView {
         ListModel {
                 id: usersModel
                 ListElement {
                         image: "home/card_1.png"
                         name: "famiglia"
                 }
                 ListElement {
                         image: "home/card_2.png"
                         name: "mattia"
                 }
                 ListElement {
                         image: "home/card_3.png"
                         name: "camilla"
                 }
                 ListElement {
                         image: "home/card_4.png"
                         name: "mamma"
                 }
                 ListElement {
                         image: "home/card_5.png"
                         name: "papà"
                 }
         }

         Component {
             id: usersDelegate
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
                     anchors.left: parent.left
                     anchors.right: parent.right
                     horizontalAlignment: Text.AlignHCenter
                 }
//                 Component.onCompleted: {
//                     console.log('icon scale: ' + PathView.iconScale + ' x:' + itemDelegate.x)
//                 }
             }
         }

         id: users
         model: usersModel
         delegate: usersDelegate

         path:  Path {
             startX: 90; startY: 200
             PathAttribute { name: "iconScale"; value: 0.4 }
             PathAttribute { name: "z"; value: 0.1 }
             PathLine { x: 150; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.5 }
             PathLine { x: 300; y: 200; }
             PathAttribute { name: "iconScale"; value: 1.0 }
             PathAttribute { name: "z"; value: 1.0 }
             PathLine { x: 420; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.6 }
             PathLine { x: 550; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.35 }
             PathLine { x: 620; y: 200; }
         }
         width: 620
         pathItemCount: 5
         anchors.bottom: favourites.top
         anchors.bottomMargin: 0
         anchors.top: toolbar.bottom
         anchors.topMargin: 0
         anchors.left: parent.left
         anchors.leftMargin: 0
    }

    Item {
         id: pages
         x: 620
         y: 65
         anchors.right: parent.right
         anchors.rightMargin: 0
         anchors.left: users.right
         anchors.leftMargin: 0
         anchors.bottom: favourites.top
         anchors.bottomMargin: 0
         anchors.top: toolbar.bottom
         anchors.topMargin: 0

    Grid {
          id: column1
          x: 116
          y: 69
          spacing: 0
          columns: 2
          anchors.top: parent.top
          anchors.topMargin: 69
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 0
          anchors.right: parent.right
          width: 288
          height: 328

              ButtonHomePageLink {
                  textFirst: false
                  source: "home/stanze.png"
              }

              ButtonHomePageLink {
                  textFirst: false
                  source: "home/sistemi.png"
                  onClicked: Stack.openPage("Systems.qml")
              }

              ButtonHomePageLink {
                  source: "home/opzioni.png"
              }


              ButtonHomePageLink {
                  source: "home/multimedia.png"
              }
        }
    }
}


