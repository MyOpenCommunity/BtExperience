import QtQuick 1.1
import Components 1.0
import Components.RssReader 1.0
import Components.Popup 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Multimedia

  \brief A page to show rss news.

  This page shows rss news feeds. The feed is shown in a linear list.
  */
Page {
    id: rssPage

    /** the URL for the RSS feed */
    property string urlString
    /** is this page in RSS 2.0 format? */
    property bool isRss: rssFeedModel.count > 0
    /** is this page in ATOM format? */
    property bool isAtom: atomFeedModel.count > 0
    /** the profile the page was opened from if any */
    property variant profile: undefined

    text: "rss"
    source: profile === undefined ? homeProperties.homeBgImage : profile.image

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

        Rectangle {
            anchors.fill: parent
            color: homeProperties.skin === HomeProperties.Clear ? "white" : "black"
            opacity: 0.9
        }

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
