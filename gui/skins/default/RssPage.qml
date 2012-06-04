import QtQuick 1.1
import Components 1.0
import Components.RssReader 1.0
import "js/Stack.js" as Stack

Page {
    id: rssPage

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    Constants {
        id: constants
    }

    NavigationBar {
        id: backButton
        systemsButton: false
        anchors.topMargin: constants.navbarTopMargin
        anchors.top: toolbar.bottom
        anchors.left: parent.left

        onBackClicked: Stack.popPage()
    }

    Item {
        id: window
        anchors {
            top: toolbar.bottom
            topMargin: parent.height / 100 * 5
            left: backButton.right
            leftMargin: 10
            right: rssPage.right
            rightMargin: 10
            bottom: rssPage.bottom
        }
        clip: true

        property bool loading: feedModel.status == XmlListModel.Loading
        property string currentFeed: "xml.corriereobjects.it/rss/homepage.xml"

        RssFeeds { id: rssFeeds }

        XmlListModel {
            id: feedModel
            source: "http://" + window.currentFeed
            query: "/rss/channel/item"

            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "link"; query: "link/string()" }
            XmlRole { name: "description"; query: "description/string()" }
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
                model: feedModel
                delegate: NewsDelegate {}
            }
        }

        ScrollBar { scrollArea: list; height: list.height; width: 8; anchors.right: window.right }
        Rectangle { x: 220; height: window.height; width: 1; color: "#cccccc" }
    }
}
