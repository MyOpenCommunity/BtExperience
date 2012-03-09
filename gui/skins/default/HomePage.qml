import QtQuick 1.1
import "Stack.js" as Stack
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module

Page {
id: mainarea
source: "images/home/home.jpg"

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
                         thumb: "images/home/fav1.png"
                 }
                 ListElement {
                         thumb: "images/home/fav2.png"
                 }
                 ListElement {
                         thumb: "images/home/fav3.png"
                 }
                 ListElement {
                         thumb: "images/home/fav4.png"
                 }
                 ListElement {
                         thumb: "images/home/fav5.png"
                 }
                 ListElement {
                         thumb: "images/home/fav6.png"
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
                         image: "images/home/card_1.png"
                         name: "famiglia"
                 }
                 ListElement {
                         image: "images/home/card_2.png"
                         name: "mattia"
                 }
                 ListElement {
                         image: "images/home/card_3.png"
                         name: "camilla"
                 }
                 ListElement {
                         image: "images/home/card_4.png"
                         name: "mamma"
                 }
                 ListElement {
                         image: "images/home/card_5.png"
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
             startX: 100; startY: 250
             PathAttribute { name: "iconScale"; value: 0.4 }
             PathAttribute { name: "z"; value: 0.1 }
             PathLine { x: 160; y: 250; }
             PathAttribute { name: "iconScale"; value: 0.5 }
             PathLine { x: 310; y: 210; }
             PathAttribute { name: "iconScale"; value: 1.0 }
             PathAttribute { name: "z"; value: 1.0 }
             PathLine { x: 420; y: 243; }
             PathAttribute { name: "iconScale"; value: 0.6 }
             PathLine { x: 560; y: 252; }
             PathAttribute { name: "iconScale"; value: 0.35 }
             PathLine { x: 630; y: 250; }
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
          x: 92
          y: 22
          spacing: 0
          columns: 2
          anchors.top: parent.top
          anchors.topMargin: 22
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 48
          anchors.right: parent.right
          anchors.rightMargin: 24
          width: 288
          height: 328

              ButtonHomePageLink {
                  textFirst: false
                  source: "images/home/stanze.png"
                  text: qsTr("stanze")
                  onClicked: Stack.container.animation.source = "SlideAnimation.qml"
                  textLeftMargin: 70
              }

              ButtonHomePageLink {
                  textFirst: false
                  source: "images/home/sistemi.png"
                  text: qsTr("sistemi")
                  textLeftMargin: 30
                  onClicked: Stack.openPage("Systems.qml")
              }

              ButtonHomePageLink {
                  source: "images/home/opzioni.png"
                  textLeftMargin: 70
                  text: qsTr("opzioni")
                  onClicked: Stack.openPage("Settings.qml")
              }


              ButtonHomePageLink {
                  source: "images/home/multimedia.png"
                  text: qsTr("multimedia")
                  textLeftMargin: 18
                  onClicked: Stack.openPage("Browser.qml")
              }
        }
    }
}


