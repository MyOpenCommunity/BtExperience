import QtQuick 1.1
import Components 1.0
import Components.RssReader 1.0
import "js/Stack.js" as Stack

Page {
    id: rssPage

    property string urlString
    property bool isRss: rssFeedModel.count > 0
    property bool isAtom: atomFeedModel.count > 0
    property variant profile: undefined

    text: "rss"

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

        property bool loading: (rssFeedModel.status == XmlListModel.Loading) || (atomFeedModel.status == XmlListModel.Loading)
        property string currentFeed: rssPage.urlString

        RssFeeds { id: rssFeeds }

        XmlListModel {
            id: rssFeedModel
            source: window.currentFeed
            query: "/rss/channel/item"

            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "link"; query: "link/string()" }
            XmlRole { name: "description"; query: "description/string()" }
        }

        XmlListModel {
            id: atomFeedModel
            source: window.currentFeed
            query: "/feed/entry"
            // the following must be present or ATOM feeds will not work
            namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';"

            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "link"; query: "link/string()" }
            XmlRole { name: "description"; query: "summary/string()" }
        }

        Row {
            Rectangle {
                width: 220; height: window.height
                color: "#efefef"

                ListView {
                    id: categories
                    anchors.fill: parent
                    model: rssFeeds
                    delegate: CategoryDelegate {}
                    highlight: Rectangle { color: "steelblue" }
                    highlightMoveSpeed: 9999999
                    interactive: false
                }
                ScrollBar {
                    scrollArea: categories; height: categories.height; width: 8
                    anchors.right: categories.right
                }
            }
            ListView {
                id: list
                width: window.width - 220; height: window.height
                model: isRss ? rssFeedModel : atomFeedModel
                delegate: NewsDelegate {}
            }
        }

        ScrollBar { scrollArea: list; height: list.height; width: 8; anchors.right: window.right }
        Rectangle { x: 220; height: window.height; width: 1; color: "#cccccc" }
    }
}
