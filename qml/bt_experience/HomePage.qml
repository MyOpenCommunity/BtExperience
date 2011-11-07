import QtQuick 1.1
import "Stack.js" as Stack

Page {
id: mainarea
source: "bg.png"

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
                         image: "profiles/camilla.jpg"
                         name: "camilla"
                 }
                 ListElement {
                         image: "profiles/mattia.jpg"
                         name: "mattia"
                 }
                 ListElement {
                         image: "profiles/papa.jpg"
                         name: "papà"
                 }
                 ListElement {
                         image: "profiles/mamma.jpg"
                         name: "mamma"
                 }
                 ListElement {
                         image: "profiles/famiglia.jpg"
                         name: "famiglia"
                 }
         }

         Component {
                 id: usersDelegate
                 Image {
                     id: imageDelegate
                     scale: isNaN(PathView.iconScale) ? 0.1 : PathView.iconScale
                     z: isNaN(PathView.z) ? 0.1 : PathView.z
                     Rectangle {
                             id: userBox
                             height: 50
                             anchors.left: parent.left
                             anchors.bottom: parent.bottom
                             anchors.right: parent.right
                             opacity: 0.4
                             color: "#000000"

                             Text {
                                 opacity: 1
                                 color: "#ffffff"
                                 text: name
                                 font.bold: false
                                 font.pixelSize: 18
                                 anchors.horizontalCenter: parent.horizontalCenter
                                 anchors.verticalCenter: parent.verticalCenter
                             }
                     }

                     source: image
                     smooth: true
                     width: 230
                     height: 350
                     fillMode: Image.PreserveAspectCrop
                     clip: true
//                     Component.onCompleted: {
//                         console.log('icon scale: ' + PathView.iconScale + ' x:' + imageDelegate.x)
//                     }
               }
         }

         id: users
         model: usersModel
         delegate: usersDelegate

         path:  Path {
             startX: 100; startY: 200
             PathAttribute { name: "iconScale"; value: 0.3 }
             PathAttribute { name: "z"; value: 0.1 }
             PathLine { x: 150; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.5 }
             PathLine { x: 350; y: 200; }
             PathAttribute { name: "iconScale"; value: 1.0 }
             PathAttribute { name: "z"; value: 1.0 }
             PathLine { x: 550; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.5 }
             PathLine { x: 650; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.3 }
             PathAttribute { name: "z"; value: 0.1 }
             PathLine { x: 750; y: 200; }

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
         x: 480
         y: 50
         anchors.right: parent.right
         anchors.rightMargin: 0
         anchors.left: users.right
         anchors.leftMargin: 0
         anchors.bottom: favourites.top
         anchors.bottomMargin: 0
         anchors.top: toolbar.bottom
         anchors.topMargin: 0

    Column {
          id: column1
          anchors.top: parent.top
          anchors.topMargin: 10
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 10
          anchors.right: parent.right
          width: 190
          spacing: 5

          ButtonHomePageLink {
              width: parent.width
              height: 85
              text: "multimedia"
              icon: "pages/ico_multimedia.png"
          }

          ButtonHomePageLink {
              width: parent.width
              height: 85
              text: "stanze"
              icon: "pages/ico_stanze.png"
              x_origin: x + width
              y_origin: 0
          }

          ButtonHomePageLink {
              width: parent.width
              height: 85
              text: "sistemi"
              icon: "pages/ico_sistemi.png"
              x_origin: x + width
              y_origin: 0
              onClicked: Stack.openPage("Systems.qml")
          }

          ButtonHomePageLink {
              width: parent.width
              height: 85
              text: "opzioni"
              icon: "pages/ico_opzioni.png"
              x_origin: x + width
              y_origin: 0
          }
        }
    }
}


