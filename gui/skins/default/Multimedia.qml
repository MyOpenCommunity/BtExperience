import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: multimedia
    source: "images/multimedia.jpg"

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onHomeClicked: Stack.backToHome()
    }

    UbuntuLightText {
        id: pageTitle
        text: qsTr("Multimedia")
        font.pixelSize: 50
        anchors {
            top: toolbar.bottom
            left: parent.left
            leftMargin: 20
        }
    }

    CardView {
        id: cardView
        function selectImage(item) {
            if (item === "usb")
                return "images/multimedia/usb.png"
            else if (item === "rss")
                return "images/multimedia/rss.png"
            else if (item === "weblink")
                return "images/multimedia/weblink.png"
            console.log("Unknown item, default to usb")
            return "images/multimedia/usb.png"
        }

        anchors {
            right: parent.right
            rightMargin: 30
            left: parent.left
            leftMargin: 30
            top: pageTitle.bottom
            topMargin: 50
            bottom: parent.bottom
        }

        model: multimediaModel
        delegate: CardDelegate {
            source: cardView.selectImage(cardView.model.get(index).itemText)
            label: cardView.model.get(index).itemText

            onClicked: Stack.openPage("Photo.qml")
        }
        delegateSpacing: 20
        visibleElements: 4

        ListModel {
            id: multimediaModel
            ListElement {
                itemText: "usb"
            }
            ListElement {
                itemText: "rss"
            }
            ListElement {
                itemText: "weblink"
            }
        }
    }
}
