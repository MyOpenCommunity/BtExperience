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
            property variant itemObject: cardView.model.get(index)
            source: cardView.selectImage(itemObject.itemText)
            label: itemObject.itemText

            onClicked: Stack.openPage(itemObject.target, itemObject.props)
        }
        delegateSpacing: 20
        visibleElements: 4
    }

    ListModel {
        id: multimediaModel
    }

    Component.onCompleted: {
        multimediaModel.append({"itemText": qsTr("usb"),
                                "target": "FileBrowser.qml",
                                "props": {"rootPath": ["media", "usb1"],
                                       "text": qsTr("usb")}
                               })
        multimediaModel.append({"itemText": qsTr("rss"), "target": "Photo.qml", "props": {}})
        multimediaModel.append({"itemText": qsTr("weblink"), "target": "Photo.qml", "props": {}})
    }
}
