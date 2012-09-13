import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


Page {
    id: multimedia

    source: "images/multimedia.jpg"
    text: qsTr("multimedia")

    ControlPathView {
        id: cardView

        visible: multimediaModel.count >= 3
        x0FiveElements: 150
        x0ThreeElements: 200
        y0: 200
        x1: 482
        y1: 150
        x2FiveElements: 814
        x2ThreeElements: 764

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
        onClicked: Stack.openPage(delegate.target, delegate.props)
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
            source: itemObject.image
            label: itemObject.description

            onClicked: Stack.openPage(itemObject.target, itemObject.props)
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

    Component.onCompleted: {
        multimediaModel.append({"description": qsTr("devices"), "target": "Devices.qml", "image": "images/multimedia/usb.png", "props": {} })

        // TODO to be implemented
        multimediaModel.append({"description": qsTr("browser"), "target": "Devices.qml", "image": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"description": qsTr("rss"), "target": "Devices.qml", "image": "images/multimedia/rss.png", "props": {}})
        multimediaModel.append({"description": qsTr("ip radio"), "target": "Devices.qml", "image": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"description": qsTr("weather"), "target": "Devices.qml", "image": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"description": qsTr("web browser"), "target": "Devices.qml", "image": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"description": qsTr("web link"), "target": "Devices.qml", "image": "images/multimedia/weblink.png", "props": {}})
    }
}
