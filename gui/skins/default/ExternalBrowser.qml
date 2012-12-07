import QtQuick 1.1
import BtExperience 1.0
import "js/Stack.js" as Stack
import Components 1.0

// This page is only used to keep track of browser position in the page stack
BasePage {
    id: webBrowser

    property string urlString

    Rectangle {
        id: blackBg
        anchors.fill: parent
        color: "#4F4F4F"
        opacity: 1
    }

    onVisibleChanged: global.browser.visible = visible
    onUrlStringChanged: global.browser.displayUrl(urlString)

    Connections {
        target: global.browser
        onRunningChanged: {
            if (!global.browser.running)
                Stack.popPage()
        }
    }

    Component.onDestruction: global.browser.visible = false
}
