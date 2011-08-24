import QtQuick 1.0
import "Stack.js" as Stack
import "Library.js" as Library

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
     id: mainText

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
     id: backButton
     source: "common/tasto_indietro.png"
     anchors.left: mainText.right
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
//         PropertyChanges { target: backButton; source: "common/tasto_indietroP.png" }
//         PropertyChanges { target: arrow_left; source: "common/freccia_sxS.png" }
     }
 }

 ListView {
     id: itemList
     y: 80
     height: 350
     anchors.left: backButton.right
     anchors.leftMargin: 20
     currentIndex: -1


     delegate: Item {
         height: 50
         width: background.sourceSize.width

         Image {
             anchors.fill: parent
             z: 0
             id: background
             source: "common/tasto_menu.png";
         }

         Item {
             anchors.fill: parent
             z: 1

             Image {
                 id: icon_status
                 source: isOn === true ? "common/on.png" :"common/off.png";
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
         MouseArea {
             anchors.fill: parent
             onClicked: {
                 itemList.currentIndex = index
                 itemDetails.visible = true
                 Library.showItem(componentFile, itemDetails)
             }
         }

         states: State {
             name: "selected"
             when: ListView.isCurrentItem
             PropertyChanges { target: text; color: "#ffffff" }
             PropertyChanges { target: arrow_right; source: "common/freccia_dxS.png" }
             PropertyChanges { target: background; source: "common/tasto_menuS.png" }
         }
     }

     model: ListModel {
         ListElement {
             name: "lampada scrivania"
             isOn: true
             componentFile: "lights/Light.qml"
         }

         ListElement {
             name: "lampadario soggiorno"
             isOn: false
             componentFile: "lights/Light.qml"
         }

         ListElement {
             name: "faretti soggiorno"
             isOn: false
             componentFile: "lights/Dimmer.qml"
         }

         ListElement {
             name: "lampada da terra soggiorno"
             isOn: false
             componentFile: "lights/Light.qml"
         }

         ListElement {
             name: "abat jour"
             isOn: true
             componentFile: "lights/Light.qml"
         }

         ListElement {
             name: "abat jour"
             isOn: true
             componentFile: "lights/Light.qml"
         }

         ListElement {
             name: "lampada studio"
             isOn: true
             componentFile: "lights/Light.qml"
         }
     }
 }

 Item {
     id: itemDetails
     x: 416
     y: 80
     width: 194
     height: 350
     visible: false
 }

}
