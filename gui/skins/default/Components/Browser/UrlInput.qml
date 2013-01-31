import QtQuick 1.0
import Components 1.0
import Components.Text 1.0

 Item {
     id: container

     property alias image: bg.source
     property alias url: urlText.text
     property variant view
     property bool ssl

     signal urlEntered(string url)
     signal urlChanged

     width: parent.height; height: parent.height

     BorderImage {
         id: bg; rotation: 180
         x: 8; width: parent.width - 16; height: 30;
         anchors.verticalCenter: parent.verticalCenter
         border { left: 10; top: 10; right: 10; bottom: 10 }
     }

     Rectangle {
         anchors.bottom: bg.bottom
         x: 18; height: 4; color: "#63b1ed"
         width: (bg.width - 20) * view.progress
         opacity: view.progress === 1.0 ? 0.0 : 1.0
     }

     UbuntuMediumTextInput {
         id: urlText
         horizontalAlignment: TextEdit.AlignLeft
         font.pixelSize: 14
         selectedTextColor: "white"
         selectionColor: "royalblue"
         onFocusChanged: {
             if (focus)
                 focusTimer.start()
         }

         // We get a focus event then a mouse click, so we immediately lose the
         // selection. Workaround suggested in:
         // http://comments.gmane.org/gmane.comp.lib.qt.qml/2650
         Timer {
             id: focusTimer
             interval: 1
             onTriggered: urlText.selectAll()
         }

         onTextChanged: container.urlChanged()

         Keys.onEscapePressed: {
             urlText.text = view.url
             view.focus = true
         }

         Keys.onEnterPressed: {
             container.urlEntered(urlText.text)
             view.focus = true
         }

         Keys.onReturnPressed: {
             container.urlEntered(urlText.text)
             view.focus = true
         }

         anchors {
             left: parent.left; right: parent.right; leftMargin: 18; rightMargin: 18
             verticalCenter: parent.verticalCenter
         }
     }

     SvgImage {
         id: sslIcon

         source: "../../images/common/ico_lock.svg"
         visible: ssl

         anchors {
             left: parent.left; leftMargin: 3
             verticalCenter: parent.verticalCenter
         }
     }
 }
