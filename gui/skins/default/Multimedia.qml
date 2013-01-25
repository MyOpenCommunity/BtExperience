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

    SystemsModel { id: webLinkSystemUii; systemId: Container.IdMultimediaWebLink; source: myHomeModels.mediaContainers }
    ObjectModel { id: webLinkModel; source: myHomeModels.mediaLinks; containers: [webLinkSystemUii.systemUii] }
    SystemsModel { id: rssSystemUii; systemId: Container.IdMultimediaRss; source: myHomeModels.mediaContainers }
    ObjectModel { id: rssModel; source: myHomeModels.mediaLinks; containers: [rssSystemUii.systemUii] }
    SystemsModel { id: webRadioSystemUii; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }
    ObjectModel { id: webRadioModel; source: myHomeModels.mediaLinks; containers: [webRadioSystemUii.systemUii] }
    SystemsModel { id: rssMeteoSystemUii; systemId: Container.IdMultimediaRssMeteo; source: myHomeModels.mediaContainers }
    ObjectModel { id: rssMeteoModel; source: myHomeModels.mediaLinks; containers: [rssMeteoSystemUii.systemUii] }
    SystemsModel { id: webcamSystemUii; systemId: Container.IdMultimediaWebCam; source: myHomeModels.mediaContainers }
    ObjectModel { id: webcamModel; source: myHomeModels.mediaLinks; containers: [webcamSystemUii.systemUii] }

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
            model: emptyModel
            pathOffset: multimediaModel.count === 4 ? -40 : (multimediaModel.count === 6 ? -40 : 0)
            arrowsMargin: multimediaModel.count === 4 ? 70 : (multimediaModel.count === 6 ? 30 : 10)
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

            model: emptyModel
        }
    }

    ListModel {
        id: emptyModel

        function getObject(index) {
            return get(index)
        }
    }

    ListModel {
        id: multimediaModel

        function getObject(index) {
            return get(index)
        }
    }

    Component.onCompleted: {
        // it is not possible to load data to multimediaModel if it is binded to both
        // pathView and listView, because strange things happen (for example, offset
        // computation is wrong because pathView "thinks" to have only 4 elements)
        // solution is to define an empty model and initially bind it to views
        // then load data on true model and bind it to views only when all data
        // is ready
        // please note that this problem may actually happen only here because
        // this is the only model with variable "length" during program execution
        multimediaModel.append({"description": qsTr("devices"), "target": "Devices.qml", "cardImageCached": "images/card/devices_card.jpg", "props": {} })
        multimediaModel.append({"description": qsTr("web browser"), "target": undefined, "cardImageCached": "images/card/browser_card.jpg", "props": {"urlString": global.homePageUrl}})
        if (webLinkModel.count > 0)
            multimediaModel.append({"description": qsTr("web link"), "target": "BrowserPage.qml", "cardImageCached": "images/card/weblink_card.jpg",
                                       "props": {"containerId": Container.IdMultimediaWebLink, "type": "browser"}})
        if (rssModel.count > 0)
            multimediaModel.append({"description": qsTr("rss"), "target": "BrowserPage.qml", "cardImageCached": "images/card/rss_card.jpg",
                                       "props": {"containerId": Container.IdMultimediaRss, "type": "rss"}})
        if (webRadioModel.count > 0)
            multimediaModel.append({"description": qsTr("ip radio"), "target": "BrowserPage.qml", "cardImageCached": "images/card/browser_card.jpg",
                                       "props": {"containerId": Container.IdMultimediaWebRadio, "type": "webradio"}})
        if (rssMeteoModel.count > 0)
            multimediaModel.append({"description": qsTr("weather"), "target": "BrowserPage.qml", "cardImageCached": "images/card/meteo_card.jpg",
                                       "props": {"containerId": Container.IdMultimediaRssMeteo, "type": "rss"}})
        if (webcamModel.count > 0)
            multimediaModel.append({"description": qsTr("web cam"), "target": "BrowserPage.qml", "cardImageCached": "images/card/webcam_card.jpg",
                                       "props": {"containerId": Container.IdMultimediaWebCam, "type": "browser"}})

        viewLoader.item.model = multimediaModel
    }
}
