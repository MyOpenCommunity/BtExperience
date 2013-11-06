/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import Components.Browser 1.0
import "js/MainContainer.js" as Container


/**
  \ingroup Core

  \brief The browser main page.

  The browser is implemented in a separate process and rendered separately.
  This is the home page for the browser application.
  */
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

    property url url: global.url

    Component {
        id: browserComponent

        BasePage {
            id: browserItem

            Connections {
                target: global
                onAuthenticationRequired: {
                    browserItem.installPopup(credentialsPopup)
                }
                onUntrustedSslConnection: {
                    browserItem.installPopup(untrustedSslPopup)
                }
            }

            objectName: "browserItem"

            Rectangle {
                // this is needed to hide pages below the current one
                anchors.fill: parent
                color: "white"
            }

            Header {
                id: header
                view: webView
                browser: webBrowser
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                onFavoritesBarClicked: {
                    if (favoritesBar.state === "hidden")
                        favoritesBar.state = "visible"
                    else
                        favoritesBar.state = "hidden"
                }
                onZoomBarClicked: {
                    if (zoomBar.state === "hidden")
                        zoomBar.state = "visible"
                    else
                        zoomBar.state = "hidden"
                    updateImages(zoomBar.state)
                }
                onUrlEntered: {
                    if (url === global.urlString)
                        webView.reload.trigger()
                    else
                        global.urlString = url
                }
            }

            Connections {
                target: global
                onRequestComplete: {
                    // ignore sub-requests
                    if (originating_request)
                        header.ssl = ssl
                }
            }

            ZoomBar {
                id: zoomBar
                state: "hidden"
                z: webViewContaineer.z + 1
                anchors {
                    top: header.bottom
                    right: header.right
                }

                function changeZoom(delta) {
                    if (zoomPercentage + delta < 100 || zoomPercentage + delta > 500)
                        return
                    zoomPercentage += delta
                }

                onZoomInClicked: changeZoom(10)
                onZoomOutClicked: changeZoom(-10)
                onZoomHundredClicked: zoomPercentage = 100
            }

            FavoritesBar {
                id: favoritesBar
                page: browserItem
                webView: webView
                state: "hidden"
                z: webViewContaineer.z + 1
                anchors {
                    top: header.bottom
                    left: header.left
                    leftMargin: header.favoritesMargin
                }
            }

            Connections {
                target: global
                onAddWebRadio: favoritesBar.displayEditPopup(url, MediaLink.WebRadio)
            }

            Pannable {
                id: webViewContaineer
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                width: parent.width

                Connections {
                    target: webBrowser
                    onUrlChanged: {
                        if (url == "_btexperience:blank")
                            webView.html = " "
                        else
                            webView.url = url
                    }
                }

                FlickableWebView {
                    id: webView
                    clip: true
                    onProgressChanged: header.urlChanged = false
                    y: parent.childOffset
                    width: parent.width
                    height: parent.height
                    zoomPercentage: zoomBar.zoomPercentage
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

    Component {
        id: untrustedSslPopup

        TextDialog {

            function okClicked() {
                global.addSecurityException()
            }

            function cancelClicked() {
                global.abortConnection()
            }

            title: qsTr("Unreliable SSL connection")
            titleColor: "red"
            text: qsTr("This connection is unreliable. Do you wish to continue?")

        }
    }
}
