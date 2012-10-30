import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack


SystemPage {
    id: page

    source: "images/multimedia.jpg"
    text: qsTr("multimedia")

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: ipRadiosModel
        containers: [deviceModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: sourceModel
        filters: [{objectId: ObjectInterface.IdSoundSource}]
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
                    var ipSource = undefined
                    for (var k = 0; k < sourceModel.count; ++k)
                    {
                        var src = sourceModel.getObject(k)
                        if (src.sourceType !== SourceObject.IpRadio)
                            continue
                        ipSource = src
                        break
                    }
                    var urls = []
                    for (var i = 0; i < ipRadiosModel.count; ++i) {
                        urls.push(ipRadiosModel.getObject(i).path)
                    }
                    if (ipSource)
                        ipSource.startPlay(urls, index, ipRadiosModel.count)
                    else
                        console.log("Ip Radio Source not defined/configured.")
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

    function systemsButtonClicked() {
        Stack.backToMultimedia()
    }

    function systemPageClosed() {
        Stack.backToMultimedia()
    }
}
