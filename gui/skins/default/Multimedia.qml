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

    ControlPathView {
        visible: multimediaModel.count >= 3
        x0FiveElements: 150
        x0ThreeElements: 250
        x1: 445
        x2FiveElements: 740
        x2ThreeElements: 640

        model: multimediaModel
        anchors {
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            top: toolbar.bottom
            topMargin: 50
            bottom: parent.bottom
        }
        pathOffset: model.count === 4 ? -40 : (model.count === 6 ? -40 : 0)
        arrowsMargin: model.count === 4 ? 70 : (model.count === 6 ? 30 : 10)
        onClicked: handleClick(delegate)
    }

    CardView {
        anchors {
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            top: toolbar.bottom
            topMargin: 50
            bottom: parent.bottom
        }
        visible: model.count < 3
        delegate: CardDelegate {
            property variant itemObject: multimediaModel.getObject(index)
            source: itemObject.cardImageCached
            label: itemObject.description

            onClicked: handleClick(itemObject)
        }

        delegateSpacing: 40
        visibleElements: 2

        model: multimediaModel
    }

    ListModel {
        id: multimediaModel

        function getObject(index) {
            return get(index)
        }
    }

    function handleClick(item) {
        if (item.target === global.browser)
            global.browser.displayUrl(item.props.urlString)
        else
            Stack.goToPage(item.target, item.props)
    }

    Component.onCompleted: {
        multimediaModel.append({"description": qsTr("devices"), "target": "Devices.qml", "cardImageCached": "images/multimedia/devices_card.jpg", "props": {} })
        multimediaModel.append({"description": qsTr("web browser"), "target": global.browser, "cardImageCached": "images/multimedia/browser_card.jpg", "props": {"urlString": "http://www.google.it"}})
        multimediaModel.append({"description": qsTr("web link"), "target": "BrowserPage.qml", "cardImageCached": "images/multimedia/browser_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaWebLink, "type": "browser"}})
        multimediaModel.append({"description": qsTr("rss"), "target": "BrowserPage.qml", "cardImageCached": "images/multimedia/rss_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaRss, "type": "rss"}})
        multimediaModel.append({"description": qsTr("ip radio"), "target": "BrowserPage.qml", "cardImageCached": "images/multimedia/weblink_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaWebRadio, "type": "webradio"}})
        multimediaModel.append({"description": qsTr("weather"), "target": "BrowserPage.qml", "cardImageCached": "images/multimedia/meteo_card.jpg",
                                   "props": {"containerId": Container.IdMultimediaRssMeteo, "type": "rss"}})
    }
}
