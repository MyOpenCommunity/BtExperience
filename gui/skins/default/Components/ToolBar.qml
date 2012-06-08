import QtQuick 1.1
import BtExperience 1.0
import "../js/datetime.js" as DateTime


Item {
    id: toolbar

    property string imagesPath: "../images/"
    property int fontSize: 17
    signal homeClicked

    width: 1024
    height: toolbar_top.height + toolbar_bottom.height

    SvgImage {
        id: toolbar_top
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        source: imagesPath + "toolbar/toolbar_bg_top.svg"
        width: parent.width
    }

    Row {
        id: toolbarLeft
        anchors.verticalCenter: toolbar_top.verticalCenter
        anchors.left: toolbar_top.left

        Item {
            width: 100
            height: toolbar_top.height

            SvgImage {
                source: imagesPath + "toolbar/icon_home.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: toolbar.homeClicked()
                }
            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 56
            height: toolbar_top.height

            UbuntuLightText {
                id: temperature
                text: "19°C"
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 113
            height: toolbar_top.height

            UbuntuLightText {
                id: date
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                function setDate(d) {
                    text = DateTime.format(d)["date"]
                }
            }
        }


        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 65
            height: toolbar_top.height

            UbuntuLightText {
                id: time
                text: DateTime.format()["time"]
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                function setTime(d) {
                    text = DateTime.format(d)["time"]
                }
            }
        }

        Timer {
            id: changeDateTime
            interval: 500
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: { var d = new Date(); date.setDate(d); time.setTime(d) }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }
    }

    SvgImage {
        source: imagesPath + "toolbar/toolbar_logo_white.svg"
        anchors.verticalCenter: toolbar_top.verticalCenter
        anchors.horizontalCenter: toolbar_top.horizontalCenter
    }

    Row {
        id: toolbarRight
        anchors.right: toolbar_top.right
        anchors.verticalCenter: toolbar_top.verticalCenter

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: height
            height: toolbar_top.height + 10
            SvgImage {
                source: imagesPath + "toolbar/icon_alert.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: height
            height: toolbar_top.height + 10
            SvgImage {
                source: imagesPath + "toolbar/icon_antintrusion.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: height
            height: toolbar_top.height + 10
            SvgImage {
                source: imagesPath + "toolbar/icon_clock.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }
        }
    }

    SvgImage {
        id: toolbar_bottom
        anchors.top: toolbar_top.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        source: imagesPath + "toolbar/toolbar_bg_bottom.svg"
        width: parent.width
    }
}
