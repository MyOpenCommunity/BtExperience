import QtQuick 1.1
import Components 1.0
import Components.RssReader 1.0
import Components.Popup 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack

Page {
    id: rssPage

    property string urlString
    property bool isRss: rssFeedModel.count > 0
    property bool isAtom: atomFeedModel.count > 0
    property variant profile: undefined

    text: "rss"
    source: profile === undefined ? global.guiSettings.homeBgImage : profile.image

    Item {
        id: window
        anchors {
            top: toolbar.bottom
            topMargin: parent.height / 100 * 5
            left: navigationBar.right
            leftMargin: 10
            right: rssPage.right
            rightMargin: 10
            bottom: rssPage.bottom
        }
        clip: true

        XmlListModel {
            id: rssFeedModel
            source: rssPage.urlString
            query: "/rss/channel/item"

            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "link"; query: "link/string()" }
            XmlRole { name: "description"; query: "description/string()" }
        }

        XmlListModel {
            id: atomFeedModel
            source: rssPage.urlString
            query: "/feed/entry"
            // the following must be present or ATOM feeds will not work
            namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';"

            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "link"; query: "link/string()" }
            XmlRole { name: "description"; query: "summary/string()" }
        }

        ListView {
            id: list
            anchors.fill: window
            visible: false
            model: isRss ? rssFeedModel : atomFeedModel
            delegate: NewsDelegate {}
        }

        SvgImage {
            id: loadingIndicator
            source: "images/common/ico_caricamento.svg"
            anchors.centerIn: window

            Timer {
                id: loadingTimer
                interval: 250
                repeat: true
                onTriggered: loadingIndicator.rotation += 45
            }
        }

        UbuntuMediumText {
            id: noNewsLabel
            anchors.centerIn: parent
            font.pixelSize: 18
            text: qsTr("No news to display")
            visible: false
        }

        Connections {
            id: modelLoading
            target: list.model
            onStatusChanged: {
                if (status === XmlListModel.Ready) {
                    if (modelLoading.target.count === 0)
                        rssPage.state = "noNews"
                    else
                        rssPage.state = "loaded"
                }
                else if (status === XmlListModel.Error)
                    installPopup(loadFeedback)
            }
        }

        ScrollBar { scrollArea: list; height: list.height; width: 8; anchors.right: window.right }
    }

    Component {
        id: loadFeedback
        FeedbackPopup {
            isOk: false
            text: qsTr("Rss load failed")
        }
    }

    states: [
        State {
            name: "loaded"
            PropertyChanges { target: list; visible: true }
            PropertyChanges { target: loadingIndicator; visible: false }
        },
        State {
            name: "noNews"
            PropertyChanges { target: loadingIndicator; visible: false }
            PropertyChanges { target: noNewsLabel; visible: true }
        }

    ]
}
