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
             PathAttribute { name: "iconScale"; value: 0.4 }
             PathAttribute { name: "z"; value: 0.1 }
             PathLine { x: 150; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.6 }
             PathLine { x: 350; y: 200; }
             PathAttribute { name: "iconScale"; value: 1.0 }
             PathAttribute { name: "z"; value: 1.0 }
             PathLine { x: 550; y: 200; }
             PathAttribute { name: "iconScale"; value: 0.45 }
             PathLine { x: 630; y: 200; }
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
                  text: "stanze"
                  source: "pages/ico_stanze.png"
              }

              ButtonHomePageLink {
                  textFirst: false
                  text: "sistemi"
                  source: "pages/ico_sistemi.png"
                  onClicked: Stack.openPage("Systems.qml")
              }

              ButtonHomePageLink {
                  text: "opzioni"
                  source: "pages/ico_opzioni.png"
              }


              ButtonHomePageLink {
                  text: "multimedia"
                  source: "pages/ico_multimedia.png"
              }
        }
    }
}


