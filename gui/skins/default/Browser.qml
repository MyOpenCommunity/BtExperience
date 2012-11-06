import QtQuick 1.1
import QtWebKit 1.0
import "js/Stack.js" as Stack
import Components 1.0
import Components.Browser 1.0

Page {
    id: webBrowser

    property string urlString : "http://www.google.it/search?hl=it&rlz=&q=eclissi&gs_sm=e&gs_upl=1154l1995l0l2170l7l5l0l0l0l0l264l264l2-1l1l0&um=1&ie=UTF-8&tbm=isch&source=og&sa=N&tab=wi&biw=1920&bih=968&sei=bmXWTsLhHoOZ8QPvmdmlAg"
    property variant profile: undefined

    source: profile === undefined ? 'images/home/home.jpg' : 'images/home/home.jpg' // TODO: profile background image
    text: profile === undefined ? qsTr("Browser") : profile.description
    showSystemsButton: false

    Header {
        id: header
        editUrl: webBrowser.urlString
        view: webView
        browser: webBrowser
        anchors {
            top: toolbar.bottom
            left: navigationBar.right
            leftMargin: 30
            right: parent.right
            rightMargin: 30
        }
    }

    Pannable {
        id: webViewContaineer
        anchors {
            top: header.bottom
            left: navigationBar.right
            leftMargin: 30
            right: parent.right
            rightMargin: 30
            bottom: parent.bottom
        }
        width: header.width
        height: 452

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

    ScrollBar {
        scrollArea: webView; width: 8
        anchors { right: parent.right; top: toolbar.bottom; bottom: parent.bottom }
    }

    ScrollBar {
        scrollArea: webView; height: 8; orientation: Qt.Horizontal
        anchors { right: parent.right; rightMargin: 8; left: header.left; bottom: parent.bottom }
    }

    function backButtonClicked() {
        if (profile === undefined)
            Stack.backToMultimedia()
        else
            Stack.popPage()
    }
}
