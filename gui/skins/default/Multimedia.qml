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

    PathView {
        id: cardView

        property int currentPressed: -1

        model: multimediaModel
        delegate: multimediaDelegate

        Component {
            id: multimediaDelegate
            Item {
                id: itemDelegate

                property variant itemObject: multimediaModel.get(index)

                width: imageDelegate.sourceSize.width
                height: imageDelegate.sourceSize.height + textDelegate.height

                z: PathView.elementZ
                scale: PathView.elementScale

                Image {
                    id: imageDelegate
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: itemObject.itemImage
                }

                UbuntuLightText {
                    id: textDelegate
                    text: itemObject.itemText
                    font.pixelSize: 22
                    anchors.top: imageDelegate.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8
                    horizontalAlignment: Text.AlignHCenter
                }

                SvgImage {
                    id: rectPressed
                    source: global.guiSettings.skin === 0 ? "images/common/profilo_p.svg" :
                                                            "images/home_dark/home.jpg"
                    visible: false
                    anchors {
                        centerIn: imageDelegate
                        fill: imageDelegate
                    }
                    width: imageDelegate.width
                    height: imageDelegate.height
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Stack.openPage(itemObject.target, itemObject.props)
                    onPressed: itemDelegate.PathView.view.currentPressed = index
                    onReleased: itemDelegate.PathView.view.currentPressed = -1
                }

                states: State {
                    when: itemDelegate.PathView.view.currentPressed === index
                    PropertyChanges {
                        target: rectPressed
                        visible: true
                    }
                }
            }
        }

        path: Path {
            startX: multimediaModel.count < 5 ? 200 : 150; startY: cardView.height / 2
            PathAttribute { name: "elementScale"; value: 0.5 }
            PathAttribute { name: "elementZ"; value: 0.5 }
            PathLine { x: cardView.width / 2; y: cardView.height / 2 - 50 }
            PathAttribute { name: "elementScale"; value: 1.1 }
            PathAttribute { name: "elementZ"; value: 1 }
            PathLine { x: multimediaModel.count < 5 ? cardView.width - 200 : cardView.width - 150; y: cardView.height / 2 }
            PathAttribute { name: "elementScale"; value: 0.5 }
            PathAttribute { name: "elementZ"; value: 0.5 }
        }

        pathItemCount: multimediaModel.count < 5 ? 3 : 5
        highlightRangeMode: PathView.StrictlyEnforceRange
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        onFlickStarted: currentPressed = -1
        onMovementEnded: currentPressed = -1
        anchors {
            right: parent.right
            rightMargin: 30
            left: parent.left
            leftMargin: 30
            top: pageTitle.bottom
            topMargin: 50
            bottom: parent.bottom
        }
    }

    ListModel {
        id: multimediaModel
    }

    Component.onCompleted: {
        multimediaModel.append({"itemText": qsTr("Devices"), "target": "Devices.qml", "itemImage": "images/multimedia/usb.png", "props": {} })

        // TODO to be implemented
        multimediaModel.append({"itemText": qsTr("browser"), "target": "Devices.qml", "itemImage": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"itemText": qsTr("rss"), "target": "Devices.qml", "itemImage": "images/multimedia/rss.png", "props": {}})
        multimediaModel.append({"itemText": qsTr("ip radio"), "target": "Devices.qml", "itemImage": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"itemText": qsTr("weather"), "target": "Devices.qml", "itemImage": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"itemText": qsTr("web browser"), "target": "Devices.qml", "itemImage": "images/multimedia/usb.png", "props": {}})
        multimediaModel.append({"itemText": qsTr("web link"), "target": "Devices.qml", "itemImage": "images/multimedia/weblink.png", "props": {}})
    }
}
