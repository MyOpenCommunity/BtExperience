import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.Browser 1.0
import "js/MainContainer.js" as Container


BasePage {
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

            property string _fixedUrlString: privateProps.fixedAddress(webBrowser.urlString)

            Header {
                id: header
                editUrl: browserItem.browserItem
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
                    url: browserItem._fixedUrlString
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

            QtObject {
                id: privateProps

                function fixedAddress(address) {
                    if (address === "")
                        return address

                    var fixedAddress = address
                    var isHttp = (fixedAddress.toLowerCase().indexOf("http://") === 0)
                    var isHttps = (fixedAddress.toLowerCase().indexOf("https://") === 0)
                    var isProcol = (fixedAddress.toLowerCase().indexOf("://") > 0)

                    if (!isHttp && !isHttps && !isProcol)
                        fixedAddress = "http://" + fixedAddress
                    else if (!isProcol)
                        fixedAddress = "http://" + fixedAddress

                    console.log("Loading web address: " + fixedAddress)
                    return fixedAddress
                }
            }
        }
    }

    Component {
        id: webViewContainerComponent
        PopupBrowser {}
    }

    Component {
        id: credentialsPopup

        Rectangle {
            id: credentials

            signal closePopup

            width: 300
            height: 300
            color: "gray"

            Text {
                id: text1
                x: 35
                y: 65
                text: qsTr("Username")
                font.pixelSize: 12
            }

            Rectangle {
                id: rectangle1
                x: 35
                y: 86
                width: 236
                height: 20
                color: "#ffffff"

                TextInput {
                    id: userInput
                    x: 0
                    y: 0
                    width: 236
                    height: 20
                    text: qsTr("")
                    font.pixelSize: 12
                }
            }

            Text {
                id: text2
                x: 35
                y: 143
                text: qsTr("Password")
                font.pixelSize: 12
            }

            Rectangle {
                id: rectangle2
                x: 35
                y: 164
                width: 236
                height: 20
                color: "#ffffff"
                TextInput {
                    id: passwordInput
                    x: 0
                    y: 0
                    width: 236
                    height: 20
                    text: qsTr("")
                    echoMode: TextInput.Password
                    font.pixelSize: 12
                }
            }

            Text {
                id: text3
                x: 84
                y: 15
                text: qsTr("Authentication required")
                font.pixelSize: 12
            }
            Rectangle {
                id: rectangle3
                x: 189
                y: 240
                width: 82
                height: 39
                color: "#ffffff"

                Text {
                    id: text4
                    x: 24
                    y: 12
                    text: qsTr("cancel")
                    font.pixelSize: 12
                }

                MouseArea {
                    id: mouse_area2
                    x: -105
                    y: 0
                    anchors.fill: parent
                    onClicked: credentials.closePopup()
                }
            }

            Rectangle {
                id: rectangle4
                x: 84
                y: 240
                width: 82
                height: 39
                color: "#ffffff"
                Text {
                    id: text5
                    x: 24
                    y: 12
                    text: qsTr("ok")
                    font.pixelSize: 12
                }

                MouseArea {
                    id: mouse_area1
                    anchors.fill: parent
                    onClicked: {
                        global.setUsername(userInput.text)
                        global.setPassword(passwordInput.text)
                        credentials.closePopup()
                    }
                }
            }
        }
    }

    Connections {
        target: global
        onAuthenticationRequired: {
            console.log("Require authentication")
            webBrowser.installPopup(credentialsPopup)
        }
    }
}
