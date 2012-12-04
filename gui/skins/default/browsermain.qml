import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.Browser 1.0
import "js/MainContainer.js" as Container


Item {
    id: webBrowser

    property alias ubuntuLight: ubuntuLightLoader
    property alias ubuntuMedium: ubuntuMediumLoader

    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }

    Component.onCompleted: {
        Container.mainContainer = webBrowser
        browserComponent.createObject(webBrowser)
    }

    FontLoader {
        id: ubuntuLightLoader
        source: "Components/Text/Ubuntu-L.ttf"
    }

    FontLoader {
        id: ubuntuMediumLoader
        source: "Components/Text/Ubuntu-M.ttf"
    }

    property string urlString: global.url

    Component {
        id: browserComponent

        Item {
            id: browserItem
            anchors.fill: parent

            Header {
                id: header
                editUrl: webBrowser.urlString
                view: webView
                browser: webBrowser
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Pannable {
                id: webViewContaineer
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                width: parent.width

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
                anchors { right: parent.right; top: header.bottom; bottom: parent.bottom }
            }

            ScrollBar {
                scrollArea: webView; height: 8; orientation: Qt.Horizontal
                anchors { right: parent.right; rightMargin: 8; left: parent.left; bottom: parent.bottom }
            }
        }
    }

    Component {
        id: webViewContainerComponent
        PopupBrowser {}
    }
}
