import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height

    Image {
        anchors.fill: parent
        source: "../../images/common/bg_UnaRegolazione.png"

        Column {
            id: column
            width: element.width
            height: 200

            Item {
                width: parent.width
                height: 50

                UbuntuLightText {
                    id: title
                    text: qsTr("instant consumption")
                    anchors {
                        top: parent.top
                        topMargin: 10
                        left: parent.left
                        leftMargin: 10
                    }
                    font.pixelSize: 13
                }

                UbuntuLightText {
                    id: power
                    text: "32 W"
                    anchors {
                        top: title.bottom
                        left: parent.left
                        leftMargin: 10
                    }
                    font.pixelSize: 13
                }
            }

            Control3LinesButton {
                anchors {
                    right: parent.right
                    topMargin: 10
                }
                line1: qsTr("partial 1")
                line2: qsTr("since 03/05/2012 - 8:23")
                line3: "45,530 kWh"
                text: qsTr("clear")
            }

            Control3LinesButton {
                anchors {
                    right: parent.right
                    topMargin: 10
                }
                line1: qsTr("partial 2")
                line2: qsTr("since 16/05/2012 - 22:23")
                line3: "9,530 kWh"
                text: qsTr("clear")
            }
        }
    }
}
