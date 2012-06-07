import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack

Page {
    id: multimedia
    source: "images/multimedia.jpg"

    NavigationBar {
        id: systemsButton
        systemsButton: false
        anchors.left: parent.left
        anchors.top: toolbar.bottom
        anchors.topMargin: constants.navbarTopMargin
        anchors.bottom: parent.bottom

        onBackClicked: Stack.popPage()
        text: qsTr("multimedia")
    }

    Image {
        id: addWeblinkButton
        source: "images/common/btn_indietro.png"
        width: weblinkView.width
        height: 50
        anchors {
            top: systemsButton.top
            left: systemsButton.right
            leftMargin: 40
            right: multimedia.right
            rightMargin: 40
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            font.pixelSize: 16
            text: qsTr("Add a new web link")
        }

        Image {
            source: "images/common/piu.png"
            anchors.right: parent.right
            anchors.top: parent.top
        }

        MouseArea {
            anchors.fill: parent
            onClicked: console.log("Add new weblink")
        }
    }

    ListModel {
        id: weblinkModel
        ListElement {
            name: "La repubblica"
            address: "http://www.repubblica.it"
        }
        ListElement {
            name: "Il corriere della sera"
            address: "http://www.corriere.it"
        }
        ListElement {
            name: "Facebook"
            address: "http://www.facebook.com"
        }
    }

    ListView {
        id: weblinkView
        anchors {
            top: addWeblinkButton.bottom
            topMargin: 10
            left: systemsButton.right
            leftMargin: 40
            right: multimedia.right
            rightMargin: 40
            bottom: multimediaView.top
            bottomMargin: 10
        }

        interactive: false

        delegate: Image {
            source: "images/common/btn_indietro.png"
            width: parent.width
            Column {
                anchors.fill: parent
                spacing: 5
                anchors.leftMargin: 10
                anchors.topMargin: 2

                Text {
                    id: title
                    text: name
                }

                Text {
                    id: url
                    text: address
                    color: "#606060"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Stack.openPage("Browser.qml", {'urlString': address})
            }
        }

        model: weblinkModel
    }

    ListModel {
        id: multimediaModel
        ListElement {
            name: "meteo"
            index: 0
            image: "images/profiles/meteo.png"
        }
        ListElement {
            name: "rss"
            index: 1
            image: "images/profiles/news.png"
        }
        ListElement {
            name: "weblink"
            index: 2
            image: "images/profiles/web.png"
        }
    }

    ListView {
        id: multimediaView
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: model.count * 150
        height: 110
        interactive: false

        Component.onCompleted: currentIndex = 2

        orientation: ListView.Horizontal
        delegate: Image {
            id: listDelegate
            source: ListView.view.currentIndex === index ? "images/common/stanzaS.png" : "images/common/stanza.png"
            Image {
                source: image
                width: parent.width - (listDelegate.ListView.view.currentIndex === index ? 30 : 20)
                height: parent.height - (listDelegate.ListView.view.currentIndex === index ? 30 : 20)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked on item: " + name)
                        listDelegate.ListView.view.currentIndex = index
                    }
                }
            }
        }

        model: multimediaModel
    }
}
