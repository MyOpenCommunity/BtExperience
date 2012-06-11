import QtQuick 1.0
import Components.Text 1.0


Image {
     id: header

     property alias editUrl: urlInput.url
     property bool urlChanged: false
     property string imagesPath: "../../images/"

     source: "../../images/browser/titlebar-bg.png"; fillMode: Image.TileHorizontally

     x: webView.contentX < 0 ? -webView.contentX : webView.contentX > webView.contentWidth-webView.width
        ? -webView.contentX+webView.contentWidth-webView.width : 0
    y: {
         if (webView.progress < 1.0)
             return 0;
         else {
             webView.contentY < 0 ? -webView.contentY : webView.contentY > height ? -height : -webView.contentY
         }
    }
     Column {
         width: parent.width

         Item {
             width: parent.width; height: 20
             UbuntuLightText {
                 anchors.centerIn: parent
                 text: webView.title; font.pixelSize: 14; font.bold: true
                 color: "white"; styleColor: "black"; style: Text.Sunken
             }
         }

         Item {
             width: parent.width; height: 40

             Button {
                 id: backButton
                 action: webView.back; image: "../../images/browser/go-previous-view.png"
                 anchors { left: parent.left; bottom: parent.bottom }
             }

             Button {
                 id: nextButton
                 anchors.left: backButton.right
                 action: webView.forward; image: "../../images/browser/go-next-view.png"
             }

             UrlInput {
                 id: urlInput
                 anchors { left: nextButton.right; right: reloadButton.left }
                 image: "../../images/browser/display.png"
                 onUrlEntered: {
                     webBrowser.urlString = url
                     webBrowser.focus = true
                     header.urlChanged = false
                 }
                 onUrlChanged: header.urlChanged = true
             }

             Button {
                 id: reloadButton
                 anchors {/* left: webView.right; rightMargin: 10 } */right: quitButton.left; rightMargin: 10 }
                 action: webView.reload; image: "../../images/browser/view-refresh.png"
                 visible: webView.progress == 1.0 && !header.urlChanged
             }
             UbuntuLightText {
                 id: quitButton
                 color: "white"
                 style: Text.Sunken
                 anchors.right: parent.right
                 anchors.top: parent.top
                 anchors.bottom: parent.bottom
                 verticalAlignment: Text.AlignVCenter
                 horizontalAlignment: Text.AlignHCenter
                 font.pixelSize: 18
             }

             Button {
                 id: stopButton
                 anchors {/* left: webView.right; rightMargin: 10 } */right: quitButton.left; rightMargin: 10 }
                 action: webView.stop; image: "../../images/browser/edit-delete.png"
                 visible: webView.progress < 1.0 && !header.urlChanged
             }

             Button {
                 id: goButton
                 anchors { right: parent.right; rightMargin: 4 }
                 onClicked: {
                     webBrowser.urlString = urlInput.url
                     webBrowser.focus = true
                     header.urlChanged = false
                 }
                 image: "../../images/browser/go-jump-locationbar.png"; visible: header.urlChanged
             }
         }
     }
 }
