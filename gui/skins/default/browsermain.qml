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

            Rectangle {
                // this is needed to hide pages below the current one
                anchors.fill: parent
                color: "white"
            }

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
        id: credentialsPopup

        FavoriteEditPopup {
            id: credentials
            function okClicked() {
                global.setSslAuthentication(topInputText, bottomInputText)
            }

            function cancelClicked() {
                global.abortConnection()
            }

            title: qsTr("Authentication required")
            topInputLabel: qsTr("User name")
            topInputText: ""
            bottomInputLabel: qsTr("Password")
            bottomInputText: ""
            bottomInputIsPassword: true
        }
    }

    // TODO: refactor and share code!
    Component {
        id: scenarioProgramming
        Column {
            id: scenarioProgrammingColumn
            signal closePopup

            spacing: 4

            SvgImage {
                source: "images/scenarios/bg_titolo.svg"

                UbuntuMediumText {
                    text: qsTr("Untrusted SSL connection")
                    font.pixelSize: 24
                    color: "red"
                    anchors {
                        left: parent.left
                        leftMargin: parent.width / 100 * 2
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            SvgImage {
                source: "images/scenarios/bg_testo.svg"

                UbuntuMediumText {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                    color: "white"
                    text: qsTr("This connection is untrusted. Do you wish to continue?")
                    wrapMode: Text.Wrap
                    anchors {
                        right: parent.right
                        rightMargin: parent.width / 100 * 2
                        left: parent.left
                        leftMargin: parent.width / 100 * 2
                    }
                }
            }

            SvgImage {
                source: "images/scenarios/bg_ok_annulla.svg"

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: parent.width / 100 * 2
                        verticalCenter: parent.verticalCenter
                    }

                    ButtonThreeStates {
                        defaultImage: "images/common/btn_99x35.svg"
                        pressedImage: "images/common/btn_99x35_P.svg"
                        selectedImage: "images/common/btn_99x35_S.svg"
                        shadowImage: "images/common/btn_shadow_99x35.svg"
                        text: qsTr("ok")
                        font.pixelSize: 14
                        onClicked: {
                            global.addSecurityException()
                            scenarioProgrammingColumn.closePopup()
                        }
                    }

                    ButtonThreeStates {
                        defaultImage: "images/common/btn_99x35.svg"
                        pressedImage: "images/common/btn_99x35_P.svg"
                        selectedImage: "images/common/btn_99x35_S.svg"
                        shadowImage: "images/common/btn_shadow_99x35.svg"
                        text: qsTr("cancel")
                        font.pixelSize: 14
                        onClicked: {
                            global.abortConnection()
                            scenarioProgrammingColumn.closePopup()
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: global
        onAuthenticationRequired: {
            webBrowser.installPopup(credentialsPopup)
        }
        onUntrustedSslConnection: {
            webBrowser.installPopup(scenarioProgramming)
        }
    }
}
