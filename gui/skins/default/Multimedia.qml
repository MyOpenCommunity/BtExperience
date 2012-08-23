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
            if (item === qsTr("Devices"))
                return "images/multimedia/usb.png"
            else if (item === qsTr("rss"))
                return "images/multimedia/rss.png"
            else if (item === qsTr("web link"))
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
        multimediaModel.append({"itemText": qsTr("Devices"), "target": "Devices.qml", "props": {} })

        // TODO to be implemented
        multimediaModel.append({"itemText": qsTr("browser"), "target": "Devices.qml", "props": {}})
        multimediaModel.append({"itemText": qsTr("rss"), "target": "Devices.qml", "props": {}})
        multimediaModel.append({"itemText": qsTr("ip radio"), "target": "Devices.qml", "props": {}})
        multimediaModel.append({"itemText": qsTr("weather"), "target": "Devices.qml", "props": {}})
        multimediaModel.append({"itemText": qsTr("web browser"), "target": "Devices.qml", "props": {}})
        multimediaModel.append({"itemText": qsTr("web link"), "target": "Devices.qml", "props": {}})
    }
}
