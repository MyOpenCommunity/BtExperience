import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack


Page {
    id: multimedia

    source : global.guiSettings.homeBgImage
    text: qsTr("multimedia")

    function cardClicked(itemObject) {
        if (itemObject.target === undefined) {
            multimedia.processLaunched(global.browser)
            global.browser.displayUrl(itemObject.props["urlString"])
        }
        else
            Stack.goToPage(itemObject.target, itemObject.props)
    }

    Loader {
        id: viewLoader
        anchors {
            top: toolbar.bottom
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            bottom: parent.bottom
        }
        sourceComponent: multimediaModel.count >= 3 ? cardPathView : cardList
    }

    Component {
        id: cardPathView

        ControlPathView {
            x0FiveElements: 150
            x0ThreeElements: 250
            y0: 270
            x1: 445
            y1: 250
            x2FiveElements: 740
            x2ThreeElements: 640
            pathviewId: 1
            model: multimediaModel
            pathOffset: model.count === 4 ? -40 : (model.count === 6 ? -40 : 0)
            arrowsMargin: model.count === 4 ? 70 : (model.count === 6 ? 30 : 10)
            onClicked: cardClicked(delegate)
        }
    }

    Component {
        id: cardList
        CardView {
            delegate: CardDelegate {
                property variant itemObject: multimediaModel.getObject(index)
                source: itemObject.cardImageCached
                label: itemObject.description

                onClicked: cardClicked(itemObject)
            }

            delegateSpacing: 40
            visibleElements: 2

            model: multimediaModel
        }
    }

    ListModel {
        id: multimediaModel

        function getObject(index) {
            return get(index)
        }
    }

    Component.onCompleted: {
        multimediaModel.append({"description": qsTr("devices"), "target": "Devices.qml", "cardImageCached": "images/card/devices_card.jpg", "props": {} })
        multimediaModel.append({"description": qsTr("web browser"), "target": undefined, "cardImageCached": "images/card/browser_card.jpg", "props": {"urlString": "http://www.google.it"}})
        multimediaModel.append({"description": qsTr("web link"), "target": "BrowserPage.qml", "cardImageCached": "images/card/browser_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaWebLink, "type": "browser"}})
        multimediaModel.append({"description": qsTr("rss"), "target": "BrowserPage.qml", "cardImageCached": "images/card/rss_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaRss, "type": "rss"}})
        multimediaModel.append({"description": qsTr("ip radio"), "target": "BrowserPage.qml", "cardImageCached": "images/card/weblink_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaWebRadio, "type": "webradio"}})
        multimediaModel.append({"description": qsTr("weather"), "target": "BrowserPage.qml", "cardImageCached": "images/card/meteo_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaRssMeteo, "type": "rss"}})
        multimediaModel.append({"description": qsTr("web cam"), "target": "BrowserPage.qml", "cardImageCached": "images/card/weblink_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaWebCam, "type": "browser"}})
    }
}
