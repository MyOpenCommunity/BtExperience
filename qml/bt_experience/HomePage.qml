import QtQuick 1.1
import "Stack.js" as Stack

Page {
id: mainarea
source: "bg.png"

    ToolBar {
        id: toolbar
        customButton: "toolbar/ico_spegni.png"
        onCustomClicked: console.log("exit")
        fontFamily: semiBoldFont.name
        fontSize: 15
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
                         width: 133
                         height: 100
                         Image {
                             id: favouritesImage
                             source: thumb
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
         width: 800
         height: 108
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
                     scale: PathView.iconScale
                     z: PathView.z
                     Rectangle {
                             id: userBox
                             width: 50
                             anchors.left: parent.left
                             anchors.leftMargin: -1
                             anchors.top: parent.top
                             anchors.topMargin: -1
                             anchors.bottom: parent.bottom
                             opacity: 0.4
                             color: "#000000"
                     }


                     Item {
                         Text {
                             opacity: 1
                             color: "#ffffff"
                             rotation: 270
                             text: name
                             font.bold: false
                             font.pixelSize: 16
                             anchors.fill: parent
                         }
                         anchors.bottom: parent.bottom
                         anchors.left: parent.left
                         anchors.bottomMargin: 20
                         anchors.leftMargin: 10
                     }
                     source: image
                     smooth: true
                     width: 380
                     height: 210
                     transform: Rotation { origin.x: 30; origin.y: 30; axis { x: 0; y: 1; z: 0 } angle: 30 }
               }
         }

         id: users
         model: usersModel
         delegate: usersDelegate
         path:  Path {
                startX: 200; startY: 100
                PathAttribute { name: "iconScale"; value: 0.6 }
                PathAttribute { name: "z"; value: 0.0 }
                PathLine { x: 450; y: 240 }
                PathAttribute { name: "iconScale"; value: 1.0 }
                PathAttribute { name: "z"; value: 1.0 }
         }
         width: 480
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
          width: 150
          spacing: 5

          ButtonHomePageLink {
              width: parent.width
              height: 66
              text: "multimedia"
              icon: "pages/ico_multimedia.png"
          }

          ButtonHomePageLink {
              width: parent.width
              height: 66
              text: "stanze"
              icon: "pages/ico_stanze.png"
              x_origin: x + width
              y_origin: 0
          }

          ButtonHomePageLink {
              width: parent.width
              height: 66
              text: "sistemi"
              icon: "pages/ico_sistemi.png"
              x_origin: x + width
              y_origin: 0
              onClicked: Stack.openPage("Systems.qml")
          }

          ButtonHomePageLink {
              width: parent.width
              height: 66
              text: "opzioni"
              icon: "pages/ico_opzioni.png"
              x_origin: x + width
              y_origin: 0
          }
        }
    }
}


