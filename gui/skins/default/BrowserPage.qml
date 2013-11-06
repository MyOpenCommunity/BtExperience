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
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Multimedia

  \brief A page showing a list of quicklinks in a list.

  This page shows a list of quicklinks. The user may choose one of the list
  element and the page activates the link. The action is based on the quicklink
  type.
  */
Page {
    id: page

    /** the container to obtain quicklinks from */
    property int containerId: -1
    /**
      Quicklink type. The action on item selection will be different for each type. May be one of:
      - browser
      - rss
      - webradio
      */
    property string type: "browser"

    /**
      Called when multimedia button on navigation bar is clicked.
      Navigates back to multimedia page.
      */
    function multimediaButtonClicked() {
        Stack.backToMultimedia()
    }

    /**
      Called when back button on navigation bar is clicked.
      Navigates back to multimedia page.
      */
    function backButtonClicked() {
        Stack.backToMultimedia()
    }

    source: "images/background/multimedia.jpg"
    text: qsTr("multimedia")
    showMultimediaButton: true

    SystemsModel { id: linksModel; systemId: page.containerId; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: objectLinksModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: ipAllLinksModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
    }

    SvgImage {
        id: bg

        source: "images/common/bg_browse.svg"
        anchors {
            top: toolbar.bottom
            topMargin: bg.height * 11 / 100
            left: navigationBar.right
            leftMargin: bg.width * 7 / 100
        }

        PaginatorOnBackground {
            id: paginator

            elementsOnPage: 7
            model: objectLinksModel
            anchors {
                top: parent.top
                topMargin: parent.height / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 2.5
                right: parent.right
                bottom: parent.bottom
            }

            delegate: ButtonThreeStates {
                id: delegateItem
                property variant itemObject: objectLinksModel.getObject(index)
                defaultImage: "images/common/btn_weblink.svg"
                pressedImage: "images/common/btn_weblink_P.svg"
                onPressed: {
                    if (type === "browser") {
                        global.browser.displayUrl(itemObject.address)
                        page.processLaunched(global.browser)
                    }
                    else if (type === "rss")
                        Stack.pushPage("RssPage.qml", {"urlString": itemObject.address})
                    else if (type === "webradio") {
                        var items = []
                        var found = 0
                        for (var i = 0; i < ipAllLinksModel.count; ++i) {
                            items.push(ipAllLinksModel.getObject(i))
                            if (itemObject === ipAllLinksModel.getObject(i))
                                found = i
                        }
                        global.audioVideoPlayer.generatePlaylistWebRadio(items, found, ipAllLinksModel.count)
                        Stack.goToPage("AudioPlayer.qml")
                    }
                }

                UbuntuMediumText {
                    id: description
                    text: itemObject.name
                    font.pixelSize: 14
                    color: delegateItem.state === "pressed" ? "white" : "black"
                    anchors {
                        top: delegateItem.top
                        topMargin: 5
                        left: delegateItem.left
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 10
                    }
                    elide: Text.ElideMiddle
                }

                UbuntuLightText {
                    id: link
                    text: itemObject.address
                    font.pixelSize: 14
                    color: delegateItem.state === "pressed" ? "white" : "black"
                    anchors {
                        bottom: delegateItem.bottom
                        bottomMargin: 5
                        left: delegateItem.left
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 10
                    }
                    elide: Text.ElideMiddle
                }
            }
        }
    }
}
