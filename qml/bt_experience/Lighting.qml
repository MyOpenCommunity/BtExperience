import QtQuick 1.0
import "Stack.js" as Stack
import "Library.js" as Library

Page {
    id: systems
    source: "systems/illuminazione.jpg"

    ToolBar {
            id: toolbar
            fontFamily: semiBoldFont.name
            fontSize: 15
            onCustomClicked: Stack.backToHome()
    }

 Rectangle {
     anchors.left: parent.left
     anchors.leftMargin: 50
     y: 390
     id: mainText

     Text {
             color: "#ffffff"
             text: "illuminazione"
             rotation: 270
             font.pixelSize: 54
             font.family: lightFont.name
             anchors.fill: parent
     }
 }

 ButtonBack {
     id: backButton
     y: 80
     anchors.left: mainText.right
     anchors.leftMargin: 105
     onClicked: Stack.popPage()
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
                 font.family: semiBoldFont.name
                 font.pixelSize: 13
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
                 headingText.text = name
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
             componentFile: "Light.qml"
         }

         ListElement {
             name: "lampadario soggiorno"
             isOn: false
             componentFile: "Light.qml"
         }

         ListElement {
             name: "faretti soggiorno"
             isOn: false
             componentFile: "Dimmer.qml"
         }

         ListElement {
             name: "lampada da terra soggiorno"
             isOn: false
             componentFile: "Light.qml"
         }

         ListElement {
             name: "abat jour"
             isOn: true
             componentFile: "Light.qml"
         }

         ListElement {
             name: "abat jour"
             isOn: true
             componentFile: "Light.qml"
         }

         ListElement {
             name: "lampada studio"
             isOn: true
             componentFile: "Light.qml"
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

 Text {
     id: headingText
     x: 225
     y: 54
     width: 544
     height: 25
     color: "#ffffff"
     horizontalAlignment: Text.AlignHCenter
     font.pixelSize: 13
     font.family: semiBoldFont.name
     font.capitalization: Font.AllUppercase
 }

}
