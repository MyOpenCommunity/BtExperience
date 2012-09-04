import QtQuick 1.1
import BtExperience 1.0
import Components.Text 1.0
import "../js/datetime.js" as DateTime
import Components 1.0


Item {
    id: toolbar

    property string imagesPath: "../images/"
    property int fontSize: 14
    signal homeClicked

    width: 1024
    height: toolbar_top.height + toolbar_bottom.height

    SvgImage {
        id: toolbar_top
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/toolbar_bg_top.svg":
                                                imagesPath + "toolbar/toolbar_bg_top_dark.svg"
        width: parent.width
    }

    Row {
        id: toolbarLeft
        anchors.verticalCenter: toolbar_top.verticalCenter
        anchors.left: toolbar_top.left

        Item {
            width: 120
            height: toolbar_top.height

            ButtonImageThreeStates {
                defaultImageBg: imagesPath + "toolbar/bg_home.svg"
                pressedImageBg: imagesPath + "toolbar/bg_home_pressed.svg"
                defaultImage: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_home.svg":
                                                              imagesPath + "toolbar/icon_home_pressed.svg"
                pressedImage: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_home_pressed.svg":
                                                              imagesPath + "toolbar/icon_home.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                onClicked: toolbar.homeClicked() //doStuff()
            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 64
            height: toolbar_top.height

            UbuntuLightText {
                id: temperature
                text: "19°C"
                color: global.guiSettings.skin === 0 ? "black":
                                                       "white"
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
            width: 99
            height: toolbar_top.height

            UbuntuLightText {
                id: date
                color: global.guiSettings.skin === 0 ? "black":
                                                       "white"
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
            width: 64
            height: toolbar_top.height

            UbuntuLightText {
                id: time
                color: global.guiSettings.skin === 0 ? "black":
                                                       "white"
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
        source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/toolbar_logo_black.svg" :
                                                imagesPath + "toolbar/toolbar_logo_white.svg"
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
            width: 51
            height: toolbar_top.height + 10
            SvgImage {
                source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_alert.svg":
                                                        imagesPath + "toolbar/icon_alert_pressed.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 51
            height: toolbar_top.height + 10
            SvgImage {
                source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_antintrusion.svg":
                                                        imagesPath + "toolbar/icon_antintrusion_pressed.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 51
            height: toolbar_top.height + 10
            SvgImage {
                source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_clock.svg":
                                                        imagesPath + "toolbar/icon_clock_pressed.svg"
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
