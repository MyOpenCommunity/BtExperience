import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack


SystemPage {
    id: page

    property int containerUii: -1

    source: "images/multimedia.jpg"
    text: qsTr("multimedia")

    SystemsModel { id: linksModel; systemId: page.containerUii; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: objectLinksModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
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
        model: objectLinksModel

        delegate: Item {
            property variant itemObject: objectLinksModel.getObject(index)

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
                onClicked: Stack.goToPage("Browser.qml", {"urlString": itemObject.address})
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
                text: itemObject.address
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
