import QtQuick 1.1
import BtExperience 1.0
import "js/Stack.js" as Stack
import Components 1.0
import Components.Text 1.0

// This page is only used to keep track of browser position in the page stack
BasePage {
    id: webBrowser

    property string urlString

    Rectangle {
        id: blackBg
        anchors.fill: parent

        Column {
            anchors.centerIn: parent
            spacing: 20

            UbuntuMediumText {
                text: qsTr("Loading browser...")
                font.pixelSize: 18
            }

            SvgImage {
                id: loadingIndicator

                source: "images/common/ico_caricamento.svg"
                visible: true
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    id: loadingTimer
                    interval: 250
                    repeat: true
                    onTriggered: loadingIndicator.rotation += 45
                    running: true
                }
            }
        }
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
