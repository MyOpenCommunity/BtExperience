import QtQuick 1.1
import QtWebKit 1.0
import "js/Stack.js" as Stack
import Components 1.0
import Components.Browser 1.0

Page {
    id: webBrowser
    property string urlString : "http://www.google.it/search?hl=it&rlz=&q=eclissi&gs_sm=e&gs_upl=1154l1995l0l2170l7l5l0l0l0l0l264l264l2-1l1l0&um=1&ie=UTF-8&tbm=isch&source=og&sa=N&tab=wi&biw=1920&bih=968&sei=bmXWTsLhHoOZ8QPvmdmlAg"

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
        anchors.top: parent.top
    }

    Pannable {
        id: webViewContaineer
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        height: 452
        anchors.rightMargin: 0
        anchors.bottomMargin: -3
        anchors.leftMargin: 0
        anchors.topMargin: 0

        FlickableWebView {
            id: webView
            clip: true
            url: webBrowser.urlString
            onProgressChanged: header.urlChanged = false
            x: 0
            y: parent.childOffset
            width: parent.width
            height: parent.height
        }
    }

    Item {
        id: headerSpace
        x: 0
        y: 49
        width: 1024
        height: 547
        z: 4
        anchors.topMargin: -16
        anchors.top: toolbar.bottom
        scale: 1
    }

    Header {
        id: header
        x: 0
        y: 89
        editUrl: webBrowser.urlString
        width: headerSpace.width
        height: 62
        visible: true
        z: 5
        anchors.top: toolbar.bottom
    }

    ScrollBar {
        scrollArea: webView; width: 8
        anchors { right: parent.right; top: toolbar.bottom; bottom: parent.bottom }
    }

    ScrollBar {
        scrollArea: webView; height: 8; orientation: Qt.Horizontal
        anchors { right: parent.right; rightMargin: 8; left: parent.left; bottom: parent.bottom }
    }
}
