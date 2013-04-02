import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Multimedia

  \brief The main page for the multimedia system.

  This page shows all available subsystems for the multimedia system.
  The list of available subsystem is:
  - web browser: opens the browser to the home page
  - web link: opens the BrowserPage loaded with the list of web links
  - rss: opens the BrowserPage loaded with the list of rss links
  - ip radio: opens the BrowserPage loaded with the list of ip radio links
  - weather: opens the BrowserPage loaded with the list of weather links
  - web cam: opens the BrowserPage loaded with the list of web cam links
  */
Page {
    id: multimedia

    source : homeProperties.homeBgImage
    text: qsTr("multimedia")

    function cardClicked(itemObject) {
        if (itemObject.target === undefined) {
            multimedia.processLaunched(global.browser)
            global.browser.displayUrl(itemObject.props["urlString"])
        }
        else
            Stack.goToPage(itemObject.target, itemObject.props)
    }

    SystemsModel { id: browserSystemUii; systemId: Container.IdMultimediaBrowser; source: myHomeModels.mediaContainers }
    ObjectModel { id: browserModel; source: myHomeModels.mediaLinks; containers: [browserSystemUii.systemUii] }
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
        sourceComponent: undefined
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
            model: cardPathViewModel
            pathOffset: cardPathViewModel.count === 4 ? -40 : (cardPathViewModel.count === 6 ? -40 : 0)
            arrowsMargin: cardPathViewModel.count === 4 ? 70 : (cardPathViewModel.count === 6 ? 30 : 10)
            onClicked: cardClicked(delegate)
        }
    }

    Component {
        id: cardListView
        CardView {
            delegate: CardDelegate {
                property variant itemObject: cardListViewModel.getObject(index)
                source: itemObject.cardImageCached
                label: itemObject.description

                onClicked: cardClicked(itemObject)
            }

            delegateSpacing: 40
            visibleElements: 2

            model: cardListViewModel
        }
    }

    ListModel {
        id: cardPathViewModel

        function getObject(index) {
            return get(index)
        }
    }

    ListModel {
        id: cardListViewModel

        function getObject(index) {
            return get(index)
        }
    }

    Component.onCompleted: {
        // it is not possible to load data to a model if it is binded to both
        // pathView and listView, because strange things happen (for example, offset
        // computation is wrong because pathView "thinks" to have only 4 elements)
        // solution is to define an empty model and bind it to the pathview loading
        // items in the onCompleted method; once all data is appended we bind
        // the model to the pathview
        // on the other side, the cardview wants to be binded to the model before
        // we start to append data to it; if we bind it after the append operations
        // the cardview stays empty
        // please note that this problem may actually happen only here because
        // this is the only model with variable "length" during program execution
        var models = [cardPathViewModel, cardListViewModel]
        for (var i = 0; i < models.length; ++i) {
            var m = models[i]
            m.append({"description": qsTr("devices"), "target": "Devices.qml", "cardImageCached": "images/card/devices.jpg", "props": {} })

            if (browserModel.count > 0)
                m.append({"description": qsTr("web browser"), "target": undefined, "cardImageCached": "images/card/browser.jpg", "props": {"urlString": global.homePageUrl}})

            if (webLinkModel.count > 0)
                m.append({"description": qsTr("web link"), "target": "BrowserPage.qml", "cardImageCached": "images/card/weblink.jpg",
                                           "props": {"containerId": Container.IdMultimediaWebLink, "type": "browser"}})
            if (rssModel.count > 0)
                m.append({"description": qsTr("rss"), "target": "BrowserPage.qml", "cardImageCached": "images/card/rss.jpg",
                                           "props": {"containerId": Container.IdMultimediaRss, "type": "rss"}})
            if (webRadioModel.count > 0)
                m.append({"description": qsTr("ip radio"), "target": "BrowserPage.qml", "cardImageCached": "images/card/browser.jpg",
                                           "props": {"containerId": Container.IdMultimediaWebRadio, "type": "webradio"}})
            if (rssMeteoModel.count > 0)
                m.append({"description": qsTr("weather"), "target": "BrowserPage.qml", "cardImageCached": "images/card/meteo.jpg",
                                           "props": {"containerId": Container.IdMultimediaRssMeteo, "type": "rss"}})
            if (webcamModel.count > 0)
                m.append({"description": qsTr("web cam"), "target": "BrowserPage.qml", "cardImageCached": "images/card/cam.jpg",
                                           "props": {"containerId": Container.IdMultimediaWebCam, "type": "browser"}})
        }

        if (cardPathViewModel.count >= 3)
            viewLoader.sourceComponent = cardPathView
        else
            viewLoader.sourceComponent = cardListView
    }
}
