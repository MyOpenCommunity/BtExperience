import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack


Page {
    id: page

    source: "images/multimedia.jpg"
    text: qsTr("multimedia")

    SystemsModel { id: containerModel; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }
    ObjectModel {
        id: ipRadiosModel
        filters: [{"objectId": ObjectInterface.IdIpRadio}]
        containers: [containerModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorOnBackground {
        id: paginator

        elementsOnPage: 8
        buttonVisible: false
        anchors {
            top: toolbar.bottom
            topMargin: 50
            left: navigationBar.right
            leftMargin: 30
        }
        model: ipRadiosModel

        delegate: Item {
            property variant itemObject: ipRadiosModel.getObject(index)

            width: delegateBg.width
            height: delegateBg.height

            SvgImage {
                id: delegateBg
                source: "images/common/btn_weblink.svg"
            }

            ButtonThreeStates {
                id: addButton

                defaultImage: "images/common/btn_weblink.svg"
                pressedImage: "images/common/btn_weblink_P.svg"
                onClicked: {
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
                color: addButton.state === "pressed" ? "white" : "black"
                anchors {
                    top: delegateBg.top
                    topMargin: 5
                    left: delegateBg.left
                    leftMargin: 10
                }
            }

            UbuntuLightText {
                id: link
                text: itemObject.path
                font.pixelSize: 14
                color: addButton.state === "pressed" ? "white" : "black"
                anchors {
                    bottom: delegateBg.bottom
                    bottomMargin: 5
                    left: delegateBg.left
                    leftMargin: 10
                }
            }
        }
    }

    function backButtonClicked() {
        Stack.backToMultimedia()
    }
}
