import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack


Page {
    id: page

    property int containerId: -1
    property string type: "browser"
    // TODO: find a way (if any) to put this into paginator and make it work for
    // real.
    property variant realModel: type === "webradio" ? ipRadiosModel : objectLinksModel

    source: "images/multimedia.jpg"
    text: qsTr("multimedia")

    function multimediaButtonClicked() {
        Stack.backToMultimedia()
    }

    function systemPageClosed() {
        Stack.backToMultimedia()
    }

    showMultimediaButton: true

    SystemsModel { id: linksModel; systemId: page.containerId; source: myHomeModels.mediaContainers }

    MediaModel {
        id: objectLinksModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: ipRadiosModel
        filters: [{"objectId": ObjectInterface.IdIpRadio}]
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
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
            buttonVisible: false
            model: page.realModel
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
                property variant itemObject: page.realModel.getObject(index)
                defaultImage: "images/common/btn_weblink.svg"
                pressedImage: "images/common/btn_weblink_P.svg"
                onClicked: {
                    if (type === "browser")
                        Stack.pushPage("Browser.qml", {"urlString": itemObject.address})
                    else if (type === "rss")
                        Stack.pushPage("RssPage.qml", {"urlString": itemObject.address})
                    else if (type === "webradio") {
                        var urls = []
                        for (var i = 0; i < ipRadiosModel.count; ++i) {
                            urls.push(ipRadiosModel.getObject(i).path)
                        }
                        global.audioVideoPlayer.generatePlaylistWebRadio(urls, index, ipRadiosModel.count)
                        Stack.goToPage("AudioVideoPlayer.qml", {"isVideo": false})
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
                }

                UbuntuLightText {
                    id: link
                    text: type === "webradio" ? itemObject.path : itemObject.address
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

    function backButtonClicked() {
        Stack.backToMultimedia()
    }
}
