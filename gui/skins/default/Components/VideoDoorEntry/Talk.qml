import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Component.onCompleted: options.setComponent(talk)

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300
        AnimatedLoader {
            id: options
        }
    }

    Component {
        id: talk
        Column {
            Row {
                Text {
                    height: 50
                    width: 162
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Talk")
                }
                Rectangle {
                    // TODO this must be an image
                    color: "red"
                    height: 50
                    width: 50
                }
            }
            Rectangle {
                color: "red"
                width: 212
                height: 50
                Text {
                    anchors {
                        fill: parent
                        horizontalCenter: parent.horizontalCenter
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("End Call")
                }
            }
            ControlSlider {
                id: volumeSlider
                description: qsTr("volume")
                property int volume: 50
                percentage: volume
                onMinusClicked: if (volume > 0) --volume
                onPlusClicked: if (volume < 100) ++volume
            }
            Rectangle {
                color: "gray"
                width: 212
                height: 50
                Text {
                    anchors {
                        fill: parent
                        horizontalCenter: parent.horizontalCenter
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Mute")
                }
            }
        }
    }

    Component {
        id: pushToTalk
        Row {
            Text {
                height: 50
                width: 162
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Push to Talk")
            }
            Rectangle {
                color: "#ff0000"
                height: 50
                width: 50
            }
        }
    }
}
