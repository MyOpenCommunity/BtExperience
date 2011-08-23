import QtQuick 1.0
import "Stack.js" as Stack


Page {
    id: systems
    source: "systems/illuminazione.jpg"

    ToolBar {
            id: toolbar
            onCustomClicked: Stack.backToHome()
    }
     FontLoader { id: localFont; source: "MyriadPro-Light.otf" }

 Rectangle {
     anchors.left: parent.left
     anchors.leftMargin: 50
     y: 370
     id: main_text

     Text {
             color: "#ffffff"
             text: "illuminazione"
             rotation: 270
             font.pixelSize: 54
             font.family: localFont.name
             anchors.fill: parent
     }
 }

 Image {
     y: 80
     id: back_button
     source: "common/tasto_indietro.png"
     anchors.left: main_text.right
     anchors.leftMargin: 105
     Image {
         id: arrow_left
         source: "common/freccia_sx.png"
         anchors.left: parent.left
         anchors.leftMargin: 0
         anchors.top: parent.top
         anchors.topMargin: 0
     }
     MouseArea {
         id: mousearea
         anchors.fill: parent
         onClicked: Stack.popPage()

     }
     states: State {
         name: "pressed"
         when: mousearea.pressed === true;
//         PropertyChanges { target: back_button; source: "common/tasto_indietroP.png" }
//         PropertyChanges { target: arrow_left; source: "common/freccia_sxS.png" }
     }
 }

 ListView {
     id: objects_list
     y: 80
     height: 350
     anchors.left: back_button.right
     anchors.leftMargin: 20

     delegate: Item {
         height: 50
         width: background.sourceSize.width

         Image {
             anchors.fill: parent
             z: 0
             id: background
             source: "common/tasto_menu.png"
         }

         Item {
             anchors.fill: parent
             z: 1

             Image {
                 id: icon_status
                 source: is_on === true ? "common/on.png" :"common/off.png";
                 anchors.left: parent.left
                 anchors.leftMargin: 0
                 anchors.top: parent.top
                 anchors.topMargin: 0
             }

             Text {
                 id: text
                 text: name
                 wrapMode: "WordWrap"
                 anchors.left: icon_status.right
                 anchors.top: parent.top
                 anchors.topMargin: 5
                 anchors.bottom: parent.bottom
                 anchors.bottomMargin: 5
                 anchors.right: arrow_right.left
             }

             Image {
                 id: arrow_right
                 source: "common/freccia_dx.png"
                 anchors.right: parent.right
                 anchors.rightMargin: 0
                 anchors.top: parent.top
                 anchors.topMargin: 0
             }
         }
     }

     model: ListModel {
         ListElement {
             name: "lampada scrivania"
             is_on: true
         }

         ListElement {
             name: "lampadario soggiorno"
             is_on: false
         }

         ListElement {
             name: "faretti soggiorno"
             is_on: false
         }

         ListElement {
             name: "lampada da terra soggiorno"
             is_on: false
         }

         ListElement {
             name: "abat jour"
             is_on: true
         }

         ListElement {
             name: "abat jour"
             is_on: true
         }

         ListElement {
             name: "lampada studio"
             is_on: true
         }
     }
 }

}
